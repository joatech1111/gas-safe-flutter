package com.joatech.gasmax.webapi.controllers;

import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.joatech.gasmax.webapi.defines.GasMaxErrors;
import com.joatech.gasmax.webapi.domains.AppUserSafe;
import com.joatech.gasmax.webapi.domains.CustomerInfo;
import com.joatech.gasmax.webapi.domains.RestAPIResult;
import com.joatech.gasmax.webapi.exceptions.InvalidSessionIdException;
import com.joatech.gasmax.webapi.exceptions.SessionIdNotReceivedException;
import com.joatech.gasmax.webapi.services.ComboBoxTypeService;
import com.joatech.gasmax.webapi.services.CustomerInfoService;
import com.joatech.gasmax.webapi.services.UserSessionService;

/*
 * 거래처
 */
@RestController
@RequestMapping("/gas/api/customers")
public class CustomerController {

	/*================================================================
	 * Private Members
	 ================================================================*/
	private final Logger logger = LoggerFactory.getLogger(getClass());

	/*================================================================
	 * Private Autowired Members
	 ================================================================*/
	@Autowired
	private UserSessionService userSessionService;

	/*================================================================
	 * Public Rest API
	 ================================================================*/
	/*
	 * 거래처 정보 수정
	 */
	@PutMapping("")
	public RestAPIResult updateCustomerInfo(
			@RequestBody String jsonCustomerInfoData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start update customer info API : Received data - {}",  jsonCustomerInfoData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read login json data
			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonCustomerInfoData);

			CustomerInfo customerInfo = new CustomerInfo();

			JsonNode jsonNode = jsonRootNode.get("AREA_CODE");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " AREA_CODE";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setAreaCode(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_CODE");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_CODE";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuCode(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_type");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_type";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuType(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_NAME");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_NAME";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuName(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_USERNAME");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_USERNAME";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuUserName(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_TEL");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_TEL";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuTel(jsonNode.asText());
			String telFind = String.join("", customerInfo.getCuTel().split("-"));
			customerInfo.setCuTelFind(telFind);

			jsonNode = jsonRootNode.get("CU_HP");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_HP";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuHp(jsonNode.asText());

			String cuHpFind = String.join("", customerInfo.getCuHp().split("-"));
			customerInfo.setCuHpFind(cuHpFind);

			jsonNode = jsonRootNode.get("Zip_Code");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " Zip_Code";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setZipCode(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_ADDR1");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_ADDR1";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuAddr1(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_ADDR2");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_ADDR2";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuAddr2(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_Bigo1");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_Bigo1";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuBigo1(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_Bigo2");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_Bigo2";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuBigo2(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_SW_CODE");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_SW_CODE";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuSwCode(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_SW_NAME");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_SW_NAME";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuSwName(jsonNode.asText());

			jsonNode = jsonRootNode.get("CU_CUTYPE");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " CU_CUTYPE";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setCuCuType(jsonNode.asText());

			jsonNode = jsonRootNode.get("GPS_X");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " GPS_X";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setGpsX(jsonNode.asText());

			jsonNode = jsonRootNode.get("GPS_Y");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " GPS_Y";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setGpsY(jsonNode.asText());

			jsonNode = jsonRootNode.get("APP_User");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " APP_User";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			customerInfo.setAppUser(jsonNode.asText());
			CustomerInfoService customerInfoService = new CustomerInfoService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapUpdateCustomerInfoResult =  customerInfoService.updateCustomerInfoService(customerInfo);
			customerInfoService.close();
			// 🔥 resultData에 필요한 필드만 넣기
			Map<String, Object> mapResultData = new HashMap<>();
			mapResultData.put("CU_CODE", customerInfo.getCuCode());
			mapResultData.put("CU_NAME", customerInfo.getCuName());
			mapResultData.put("CU_USERNAME", customerInfo.getCuUserName());
			mapResultData.put("CU_ADDR1", customerInfo.getCuAddr1());
			mapResultData.put("CU_ADDR2", customerInfo.getCuAddr2());
			resultData = mapResultData;
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}






	/*
	 * 거래처 정보 조건 조회
	 */
	@GetMapping("/search/conditions/{area_code}")
	public RestAPIResult getCustomerInfoSearchConditionByAreaCode(
			@PathVariable("area_code") String areaCode,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get customer info search condition by area code API : Received data - {}", areaCode);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}else{
				logger.info("===============================================================");
				logger.info("appUserSafe,{} ", appUserSafe);
				logger.info("===============================================================");
			}




			ComboBoxTypeService comboBoxTypeService = new ComboBoxTypeService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listCuty = comboBoxTypeService.getComboTypeListByTypeAndAreaCode("CUTY", areaCode);
			List<Map<String, Object>> listSobi = comboBoxTypeService.getComboTypeListByTypeAndAreaCode("SOBI", areaCode);
			comboBoxTypeService.close();

			Map<String, Object> mapResult = new HashMap<String, Object>();
			mapResult.put("CUTY", listCuty);
			mapResult.put("SOBI", listSobi);

			resultData = mapResult;

		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

}
