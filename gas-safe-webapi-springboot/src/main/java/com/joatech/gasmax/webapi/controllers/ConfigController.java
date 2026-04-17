package com.joatech.gasmax.webapi.controllers;
import java.util.concurrent.*;
import java.util.stream.Collectors;
import java.io.IOException;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

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
import com.joatech.gasmax.webapi.configurations.GasMaxConfig;
import com.joatech.gasmax.webapi.defines.GasMaxErrors;
import com.joatech.gasmax.webapi.domains.AppUserSafe;
import com.joatech.gasmax.webapi.domains.ConfigSet;
import com.joatech.gasmax.webapi.domains.RestAPIResult;
import com.joatech.gasmax.webapi.exceptions.InvalidSessionIdException;
import com.joatech.gasmax.webapi.exceptions.SessionIdNotReceivedException;
import com.joatech.gasmax.webapi.services.ComboBoxTypeService;
import com.joatech.gasmax.webapi.services.ConfigSetService;
import com.joatech.gasmax.webapi.services.UserSessionService;

/*
 * 환경설정
 */
@RestController
@RequestMapping("/gas/api/config")
public class ConfigController {

	/*================================================================
	 * Private Members
	 ================================================================*/
	private final Logger logger = LoggerFactory.getLogger(getClass());

	/*================================================================
	 * Private Autowired Members
	 ================================================================*/
	@Autowired
	private UserSessionService userSessionService;
	@Autowired
	private GasMaxConfig gasMaxConfig;

	/*================================================================
	 * Public Rest API
	 ================================================================*/

	/*================================================================
	 * Public Rest API
	 ================================================================*/
	/*
	 * 환경설정 저장(SP 환경저장)
	 */
	@PutMapping("")
	public RestAPIResult updateConfig(
			@RequestBody String jsonConfigData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start put config set list API : Received data - {}",  jsonConfigData);

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
			JsonNode jsonRootNode = mapper.readTree(jsonConfigData);

			ConfigSet configSet = new ConfigSet();

			JsonNode jsonNode = jsonRootNode.get("HP_IMEI");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " HP_IMEI";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			configSet.setHpImei(jsonNode.asText());

			jsonNode = jsonRootNode.get("Login_User");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " Login_User";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			configSet.setLoginUser(jsonNode.asText());

			jsonNode = jsonRootNode.get("Login_Pass");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " Login_Pass";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			configSet.setLoginPass(jsonNode.asText());

			jsonNode = jsonRootNode.get("Safe_SW_CODE");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " Safe_SW_CODE";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			configSet.setSafeSwCode(jsonNode.asText());

			jsonNode = jsonRootNode.get("Area_CODE");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " Area_CODE";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			configSet.setAreaCode(jsonNode.asText());

			jsonNode = jsonRootNode.get("SW_CODE");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " SW_CODE";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			configSet.setSwCode(jsonNode.asText());

			jsonNode = jsonRootNode.get("Gubun_CODE");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " Gubun_CODE";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			configSet.setGubunCode(jsonNode.asText());

			jsonNode = jsonRootNode.get("JY_CODE");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " JY_CODE";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			configSet.setJyCode(jsonNode.asText());

			jsonNode = jsonRootNode.get("OrderBy");
			if (jsonNode == null) {
				result = GasMaxErrors.ERROR_DATA_NOT_FOUND + " OrderBy";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_FOUND;
				apiResult = new RestAPIResult(result, resultCode, resultData);
				return apiResult;
			}
			configSet.setOrderBy(jsonNode.asText());

			ConfigSetService configSetService = new ConfigSetService(gasMaxConfig.getDbHostname(), gasMaxConfig.getDbPortNumber(), gasMaxConfig.getDbName(), gasMaxConfig.getDbUsername(), gasMaxConfig.getDbPassword());
			Map<String, Object> mapUpdateConfigSetResult =  configSetService.updateConfigSet(configSet);
			configSetService.close();
			resultData = mapUpdateConfigSetResult;
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}


	/*
	 * 환경설정 조건 조회 전체 todo: 개선
	 */
	@GetMapping("all/{area_code}")
	public RestAPIResult getAllConfigByAreacode(
			@PathVariable("area_code") String areaCode,
			@RequestParam("sessionid") Optional<String> optSessionId)
			throws SessionIdNotReceivedException, InvalidSessionIdException {

		if (!optSessionId.isPresent()) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}

		String sessionId = optSessionId.get();
		AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
		if (appUserSafe == null) {
			throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
		}

		ComboBoxTypeService comboBoxTypeService = new ComboBoxTypeService(
				appUserSafe.getServerIp(),
				Integer.parseInt(appUserSafe.getServerPort()),
				appUserSafe.getServerDBName(),
				appUserSafe.getServerUser(),
				appUserSafe.getServerPassword()
		);

		List<String> types = Arrays.asList("SW", "MAN", "JY", "SORT", "SAFE");

		// 병렬 실행
		Map<String, CompletableFuture<List<Map<String, Object>>>> futureMap = types.stream()
				.collect(Collectors.toMap(
						type -> type,
						type -> CompletableFuture.supplyAsync(() -> comboBoxTypeService.getComboTypeListByTypeAndAreaCode(type, areaCode))
				));

		// 결과 수집
		Map<String, Object> resultData = new HashMap<>();
		for (String type : types) {
			resultData.put(type, futureMap.get(type).join());
		}

		comboBoxTypeService.close();

		return new RestAPIResult(GasMaxErrors.ERROR_OK, GasMaxErrors.ERROR_CODE_OK, resultData);
	}


	/*
	 * 환경설정 조건 조회
	 */
	@GetMapping("{type}/{area_code}")
	public RestAPIResult getConfigByTypeAndAreacode(
			@PathVariable("type") String type,
			@PathVariable("area_code") String areaCode,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			ComboBoxTypeService comboBoxTypeService = new ComboBoxTypeService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listGubunAll = comboBoxTypeService.getComboTypeListByTypeAndAreaCode(type, areaCode);
			comboBoxTypeService.close();
			resultData = listGubunAll;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@GetMapping("area/{area_code}")
	public RestAPIResult getConfigAreaListByAreaCode(
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			ComboBoxTypeService comboBoxTypeService = new ComboBoxTypeService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listGubunAll = comboBoxTypeService.getAreaComboTypeList();
			comboBoxTypeService.close();
			resultData = listGubunAll;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}


	@GetMapping("area")
	public RestAPIResult getConfigAreaList(
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			ComboBoxTypeService comboBoxTypeService = new ComboBoxTypeService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listGubunAll = comboBoxTypeService.getAreaComboTypeList();
			comboBoxTypeService.close();
			resultData = listGubunAll;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}
}
