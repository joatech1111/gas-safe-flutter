package com.joatech.gasmax.webapi.controllers;


import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Random;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.regex.Pattern;

import java.util.HashMap;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.joatech.gasmax.webapi.defines.GasMaxErrors;
import com.joatech.gasmax.webapi.domains.AnCont;
import com.joatech.gasmax.webapi.domains.AnSobi;
import com.joatech.gasmax.webapi.domains.AnSobiSafe;
import com.joatech.gasmax.webapi.domains.AnSobiSign;
import com.joatech.gasmax.webapi.domains.AnSobiTank;
import com.joatech.gasmax.webapi.domains.AppUserSafe;
import com.joatech.gasmax.webapi.domains.RestAPIResult;
import com.joatech.gasmax.webapi.domains.SafeInsertList;
import com.joatech.gasmax.webapi.domains.SafetyCustomer;
import com.joatech.gasmax.webapi.exceptions.InvalidSessionIdException;
import com.joatech.gasmax.webapi.exceptions.JsonNodeNotFoundException;
import com.joatech.gasmax.webapi.exceptions.SessionIdNotReceivedException;
import com.joatech.gasmax.webapi.services.AnSobiSafeService;
import com.joatech.gasmax.webapi.services.AnContService;
import com.joatech.gasmax.webapi.services.AnSobiService;
import com.joatech.gasmax.webapi.services.AnSobiSignService;
import com.joatech.gasmax.webapi.services.AnSobiTankService;
import com.joatech.gasmax.webapi.services.ComboBoxSectionKeywordService;
import com.joatech.gasmax.webapi.services.ComboBoxTypeService;
import com.joatech.gasmax.webapi.services.SMSNoticesService;
import com.joatech.gasmax.webapi.services.SafeCustomerHistoryService;
import com.joatech.gasmax.webapi.services.SafeInsertListService;
import com.joatech.gasmax.webapi.services.SearchSafeCustomerService;
import com.joatech.gasmax.webapi.services.UserSessionService;

import com.joatech.gasmax.webapi.controllers.FileDownloadController;





import utilities.GasMaxUtility;

/*
 * 안전점검
 */
@RestController
@RequestMapping("/gas/api/safetycheck")
public class SafeCheckController {

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
	private FileDownloadController fileDownloadController;
	/*================================================================
	 * Public Rest API
	 ================================================================*/
	/*
	 * 안전점검 거래처 검색 조건 API
	 */
	@GetMapping("/customers/search/conditions/{area_code}")
	public RestAPIResult getSafetycheckCustomerSearchConditionByAreaCode(
			@PathVariable("area_code") String areaCode,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get safetycheck customer search condition API : Received data - {}", areaCode);

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
			List<Map<String, Object>> listGubunSW = comboBoxTypeService.getComboTypeListByTypeAndAreaCode("SW", areaCode);
			List<Map<String, Object>> listGubunMan = comboBoxTypeService.getComboTypeListByTypeAndAreaCode("MAN", areaCode);
			comboBoxTypeService.close();

			ComboBoxSectionKeywordService comboKeywordService = new ComboBoxSectionKeywordService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listApt = comboKeywordService.getAllComboAptListByAreaCode(areaCode);
			comboKeywordService.close();

			Map<String, Object> mapResult =  new HashMap<String, Object>();
			mapResult.put("SW", listGubunSW);
			mapResult.put("MAN", listGubunMan);
			mapResult.put("APT", listApt);

			resultData = mapResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@PostMapping("/customers/search/keyword")
	public RestAPIResult postSafetycheckSearchKeyword(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start get Safetycheck customer search keyword API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			SafetyCustomer safetyCustomer = parseJsonSafetyCustomerInfo(false, jsonData);
			String orderBy = safetyCustomer.getOrderBy();

			SearchSafeCustomerService searchSafeCustomerService = new SearchSafeCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());

			if (orderBy.isEmpty() == true) {
				List<Map<String, Object>> listResult = searchSafeCustomerService.getAllSearchSafeCustomerBy(safetyCustomer);
				resultData = listResult;
			}
			else {
				List<Map<String, Object>> listResult = searchSafeCustomerService.getAllSearchSafeCustomerByOrderBy(safetyCustomer);
				resultData = listResult;
			}
			searchSafeCustomerService.close();
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@PostMapping("/customers/search/location")
	public RestAPIResult postSafetycheckSearchLocation(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start get Safetycheck customer search Location API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			SafetyCustomer safetyCustomer = parseJsonSafetyCustomerInfo(true, jsonData);
			String orderBy = safetyCustomer.getOrderBy();

			SearchSafeCustomerService searchSafeCustomerService = new SearchSafeCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			if (orderBy.isEmpty() == true) {
				List<Map<String, Object>> listResult = searchSafeCustomerService.getGpsAllSearchSafeCustomerBy(safetyCustomer);
				resultData = listResult;
			}
			else {
				List<Map<String, Object>> listResult = searchSafeCustomerService.getGpsAllSearchSafeCustomerByOrderBy(safetyCustomer);
				resultData = listResult;
			}

			searchSafeCustomerService.close();

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
	 * 거래처 점검이력 조회 API_2019.12.09 수정 -OrderBy 추가
	 */
	@GetMapping("/history/{area_code}/{cu_code}/{sh_date}")
	public RestAPIResult getSafetycheckHistoryByAreaCodeAndCuCodeAndShDate(
			@PathVariable("area_code") String areaCode,
			@PathVariable("cu_code") String cuCode,
			@PathVariable("sh_date") String shDate,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get safetycheck customer search condition API : Received data - {}", areaCode, cuCode, shDate);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			String orderBy = "ANZ_DATE, CHECK_TYPE";
			SafeCustomerHistoryService safeCustomerHistoryService = new SafeCustomerHistoryService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listResult = safeCustomerHistoryService.getSafeCustomerHistoryByOrderBy(areaCode, cuCode, shDate, orderBy);
			safeCustomerHistoryService.close();

			resultData = listResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@GetMapping("/equips/{area_code}/{anz_cu_code}")
	public RestAPIResult getSafetycheckAnSobiByAreaCodeAndAnzCuCode(
			@PathVariable("area_code") String areaCode,
			@PathVariable("anz_cu_code") String anzCuCode,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get safetycheck Equips API : Received data - {}", areaCode, anzCuCode);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listResult = anSobiService.getLastAnSobiServiceBy(areaCode, anzCuCode);
			anSobiService.close();

			String sign = "";
			if (listResult.isEmpty() == false) {
				String anzSno = (String) listResult.get(0).get("ANZ_Sno");
				AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
				sign = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);
				anSobiSignService.close();
			}

			Map<String, Object> mapResult = new HashMap<String, Object>();
			mapResult.put("data", listResult);
			mapResult.put("sign", sign);

			resultData = mapResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@GetMapping("/equips/{area_code}/{anz_cu_code}/{anz_sno}")
	public RestAPIResult getSafetycheckAnSobiByAreaCodeAndAnzCuCodeAndAnzSno(
			@PathVariable("area_code") String areaCode,
			@PathVariable("anz_cu_code") String anzCuCode,
			@PathVariable("anz_sno") String anzSno,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get AnSobi AreaCode AnzCuCode AnzSno API : Received data - {}", areaCode, anzCuCode, anzSno);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listResult = anSobiService.getAnSobiServiceBy(areaCode, anzCuCode, anzSno);
			anSobiService.close();

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			String sign = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);
			anSobiSignService.close();

			Map<String, Object> mapResult = new HashMap<String, Object>();
			mapResult.put("data", listResult);
			mapResult.put("sign", sign);

			resultData = mapResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@GetMapping("/equips3/{area_code}/{anz_cu_code}")
	public RestAPIResult getSafetycheckAnSobiByAreaCodeAndAnzCuCodeNew(
			@PathVariable("area_code") String areaCode,
			@PathVariable("anz_cu_code") String anzCuCode,
			@RequestParam("sessionid") Optional<String> optSessionId)
			throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get safetycheck Equips API : Received data - {}", areaCode, anzCuCode);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listResult = anSobiService.getLastAnSobiServiceBy3(areaCode, anzCuCode);
			anSobiService.close();

			String sign = "";
			if (listResult.isEmpty() == false) {
				String anzSno = (String) listResult.get(0).get("ANZ_Sno");
				AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
				sign = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);
				anSobiSignService.close();
			}

			Map<String, Object> mapResult = new HashMap<String, Object>();
			mapResult.put("data", listResult);
			mapResult.put("sign", sign);

			resultData = mapResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@GetMapping("/equips3/{area_code}/{anz_cu_code}/{anz_sno}")
	public RestAPIResult getSafetycheckAnSobiByAreaCodeAndAnzCuCodeAndAnzSnoNew(
			@PathVariable("area_code") String areaCode,
			@PathVariable("anz_cu_code") String anzCuCode,
			@PathVariable("anz_sno") String anzSno,
			@RequestParam("sessionid") Optional<String> optSessionId)
			throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get AnSobi AreaCode AnzCuCode AnzSno API : Received data - {}", areaCode, anzCuCode, anzSno);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listResult = anSobiService.getAnSobiServiceBy3(areaCode, anzCuCode, anzSno);
			anSobiService.close();

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			String sign = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);
			anSobiSignService.close();

			Map<String, Object> mapResult = new HashMap<String, Object>();
			mapResult.put("data", listResult);
			mapResult.put("sign", sign);

			resultData = mapResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}




	/*
	 * 소비설비등록  API_2019.12.09
	 */
	@PostMapping("/equips")
	public RestAPIResult postAddNewAnSobi(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Add New AnSobi API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobi anSobi = parseJsonAnSobi(false, jsonData);
			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiService.createAnSobi(anSobi);
			anSobiService.close();

			String AnzSNo = (String) mapResult.get("po_ANZ_Sno");

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobi.getAreaCode());
			anSobiSign.setAnzCuCode(anSobi.getAnzCuCode());
			anSobiSign.setAnzSno(AnzSNo);
			anSobiSign.setAnzDate(anSobi.getAnzDate());
			anSobiSign.setAnzId(anSobi.getAppUser());

			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);

			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);
			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_TRAN_INFO", "E02 소비설비점검 등록오류.");
			}
			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
	 * 소비설비점검 수정  API_2019.12.09
	 */
	@PutMapping("/equips")
	public RestAPIResult putUpdateAnSobi(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Update AnSobi API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobi anSobi = parseJsonAnSobi(false, jsonData);
			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiService.updateAnSobi(anSobi);
			anSobiService.close();

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobi.getAreaCode());
			anSobiSign.setAnzCuCode(anSobi.getAnzCuCode());
			anSobiSign.setAnzSno(anSobi.getAnzSno());
			anSobiSign.setAnzDate(anSobi.getAnzDate());
			anSobiSign.setAnzId(anSobi.getAppUser());

			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);

			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);
			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_TRAN_INFO", "E01 소비설비점검 수정오류.");
			}
			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
     * 소비설비점검 삭제   API_2019.12.09
	 */
	@DeleteMapping("/equips")
	public RestAPIResult deleteAnSobi(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Delete AnSobi API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobi anSobi = parseJsonAnSobi(true, jsonData);

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobi.getAreaCode());
			anSobiSign.setAnzCuCode(anSobi.getAnzCuCode());
			anSobiSign.setAnzSno(anSobi.getAnzSno());

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			anSobiSignService.deleteAnSobiSign(anSobiSign);
			anSobiSignService.close();

			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiService.deleteAnSobi(anSobi);
			anSobiService.close();

			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@PostMapping("/Newequips")
	public RestAPIResult postAddNewAnSobiNew(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Add New AnSobi API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobi anSobi = parseJsonAnSobiNew(false, jsonData);
			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiService.createAnSobiNew(anSobi);
			anSobiService.close();

			String AnzSNo = (String) mapResult.get("po_ANZ_Sno");

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobi.getAreaCode());
			anSobiSign.setAnzCuCode(anSobi.getAnzCuCode());
			anSobiSign.setAnzSno(AnzSNo);
			anSobiSign.setAnzDate(anSobi.getAnzDate());
			anSobiSign.setAnzId(anSobi.getAppUser());

			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);

			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);
			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_TRAN_INFO", "E02 소비설비점검 등록오류.");
			}
			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@PutMapping("/Newequips")
	public RestAPIResult putUpdateAnSobiNew(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Update AnSobi API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobi anSobi = parseJsonAnSobiNew(false, jsonData);
			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiService.updateAnSobiNew(anSobi);
			anSobiService.close();

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobi.getAreaCode());
			anSobiSign.setAnzCuCode(anSobi.getAnzCuCode());
			anSobiSign.setAnzSno(anSobi.getAnzSno());
			anSobiSign.setAnzDate(anSobi.getAnzDate());
			anSobiSign.setAnzId(anSobi.getAppUser());

			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);

			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);
			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_TRAN_INFO", "E01 소비설비점검 수정오류.");
			}
			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@DeleteMapping("/Newequips")
	public RestAPIResult deleteAnSobiNew(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Delete AnSobi API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobi anSobi = parseJsonAnSobiNew(true, jsonData);

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobi.getAreaCode());
			anSobiSign.setAnzCuCode(anSobi.getAnzCuCode());
			anSobiSign.setAnzSno(anSobi.getAnzSno());

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			anSobiSignService.deleteAnSobiSign(anSobiSign);
			anSobiSignService.close();

			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiService.deleteAnSobiNew(anSobi);
			anSobiService.close();

			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}





	@PostMapping("/NewequipsAdd")
	public RestAPIResult postAddNewAnSobiNewAdd(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
			throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Add New AnSobi API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobi anSobi = parseJsonAnSobiNew(false, jsonData);
			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiService.createAnSobiNewAdd(anSobi);
			anSobiService.close();

			String AnzSNo = (String) mapResult.get("po_ANZ_Sno");

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobi.getAreaCode());
			anSobiSign.setAnzCuCode(anSobi.getAnzCuCode());
			anSobiSign.setAnzSno(AnzSNo);
			anSobiSign.setAnzDate(anSobi.getAnzDate());
			anSobiSign.setAnzId(anSobi.getAppUser());

			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);

			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);
			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_TRAN_INFO", "E02 소비설비점검 등록오류.");
			}
			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@PutMapping("/NewequipsAdd")
	public RestAPIResult putUpdateAnSobiNewAdd(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
			throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Update AnSobi API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobi anSobi = parseJsonAnSobiNew(false, jsonData);
			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiService.updateAnSobiNewAdd(anSobi);
			anSobiService.close();

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobi.getAreaCode());
			anSobiSign.setAnzCuCode(anSobi.getAnzCuCode());
			anSobiSign.setAnzSno(anSobi.getAnzSno());
			anSobiSign.setAnzDate(anSobi.getAnzDate());
			anSobiSign.setAnzId(anSobi.getAppUser());

			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);

			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);
			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_TRAN_INFO", "E01 소비설비점검 수정오류.");
			}
			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@DeleteMapping("/NewequipsAdd")
	public RestAPIResult deleteAnSobiNewAdd(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
			throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Delete AnSobi API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobi anSobi = parseJsonAnSobiNew(true, jsonData);

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobi.getAreaCode());
			anSobiSign.setAnzCuCode(anSobi.getAnzCuCode());
			anSobiSign.setAnzSno(anSobi.getAnzSno());

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			anSobiSignService.deleteAnSobiSign(anSobiSign);
			anSobiSignService.close();

			AnSobiService anSobiService = new AnSobiService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiService.deleteAnSobiNewAdd(anSobi);
			anSobiService.close();

			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}



	@GetMapping("/sms/{area_code}")
	public RestAPIResult smsNotice(
			@PathVariable("area_code") String areaCode,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get sms API AreaCode : Received data - {}", areaCode);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			SMSNoticesService smsNoticesService = new SMSNoticesService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> smsNoticesList = smsNoticesService.getSMSNoticesByAreaCode(areaCode);
			smsNoticesService.close();
			resultData = smsNoticesList; //.get(0).get("SMS_Msg");
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
	 * 2019.12.17 수정 - SMS_DIV 추가
	 */
	@GetMapping("/sms/{area_code}/{sms_div}")
	public RestAPIResult smsNoticeSmsDiv(
			@PathVariable("area_code") String areaCode,
			@PathVariable("sms_div") String smsDiv,
			@RequestParam(value = "cont_file_url", required = false) Optional<String> optContFileUrl,
			@RequestParam(value = "preview_url", required = false) Optional<String> optPreviewUrl,
			@RequestParam(value = "anz_cu_code", required = false) Optional<String> optAnzCuCode,
			@RequestParam(value = "anz_sno", required = false) Optional<String> optAnzSno,
			@RequestParam(value = "supplier_name", required = false) Optional<String> optSupplierName,
			@RequestParam(value = "customer_name", required = false) Optional<String> optCustomerName,
			@RequestParam(value = "contract_name", required = false) Optional<String> optContractName,
			@RequestParam(value = "address", required = false) Optional<String> optAddress,
			@RequestParam(value = "inspector_name", required = false) Optional<String> optInspectorName,
			@RequestParam(value = "contract_date", required = false) Optional<String> optContractDate,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get sms API AreaCode, SmsDiv: Received data - {}", areaCode, smsDiv);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			SMSNoticesService smsNoticesService = new SMSNoticesService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> smsNoticesList = smsNoticesService.getSMSNoticesByAreaCodeAndSmsDiv(areaCode, smsDiv);
			smsNoticesService.close();

			String resolvedContFileUrl = resolveContractFileUrl(
					appUserSafe,
					areaCode,
					optContFileUrl.orElse(""),
					optAnzCuCode.orElse(""),
					optAnzSno.orElse(""));

			applySmsPlaceholders(
					smsNoticesList,
					Optional.ofNullable(resolvedContFileUrl),
					optPreviewUrl,
					optSupplierName,
					optCustomerName,
					optContractName,
					optAddress,
					optInspectorName,
					optContractDate);
			resultData = smsNoticesList; //.get(0).get("SMS_Msg");
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	private String resolveContractFileUrl(
			AppUserSafe appUserSafe,
			String areaCode,
			String contFileUrl,
			String anzCuCode,
			String anzSno) {
		String resolved = contFileUrl == null ? "" : contFileUrl.trim();
		if (!resolved.isEmpty()) return resolved;
		if (anzCuCode == null || anzCuCode.trim().isEmpty()) return "";

		AnContService anContService = null;
		try {
			anContService = new AnContService(
					appUserSafe.getServerIp(),
					Integer.parseInt(appUserSafe.getServerPort()),
					appUserSafe.getServerDBName(),
					appUserSafe.getServerUser(),
					appUserSafe.getServerPassword());

			List<Map<String, Object>> listResult;
			if (anzSno != null && !anzSno.trim().isEmpty()) {
				listResult = anContService.getAnContServiceBy(areaCode, anzCuCode.trim(), anzSno.trim());
			} else {
				listResult = anContService.getLastAnContServiceBy(areaCode, anzCuCode.trim());
			}

			if (listResult != null && !listResult.isEmpty()) {
				Object urlObj = listResult.get(0).get("CONT_FILE_URL");
				if (urlObj != null) {
					resolved = urlObj.toString().trim();
				}
			}
		} catch (Exception e) {
			logger.warn("Failed to resolve contract file url for sms. areaCode={}, anzCuCode={}, anzSno={}",
					areaCode, anzCuCode, anzSno, e);
		} finally {
			if (anContService != null) anContService.close();
		}
		return resolved;
	}

	private void applySmsPlaceholders(
			Map<String, Object> smsNoticesList,
			Optional<String> optContFileUrl,
			Optional<String> optPreviewUrl,
			Optional<String> optSupplierName,
			Optional<String> optCustomerName,
			Optional<String> optContractName,
			Optional<String> optAddress,
			Optional<String> optInspectorName,
			Optional<String> optContractDate) {
		if (smsNoticesList == null) return;
		String smsMsgKey = findSmsMsgKey(smsNoticesList);
		if (smsMsgKey == null) return;
		Object smsObj = smsNoticesList.get(smsMsgKey);
		if (!(smsObj instanceof String)) return;

		String smsMsg = (String) smsObj;
		String contFileUrl = optContFileUrl.orElse("").trim();
		String previewUrl = optPreviewUrl.orElse("").trim();
		String supplierName = optSupplierName.orElse("").trim();
		String customerName = optCustomerName.orElse("").trim();
		String contractName = optContractName.orElse("").trim();
		String address = optAddress.orElse("").trim();
		String inspectorName = optInspectorName.orElse("").trim();
		String contractDate = optContractDate.orElse("").trim();

		if (previewUrl.isEmpty() && !contFileUrl.isEmpty()) {
			previewUrl = "https://docs.google.com/gview?embedded=true&url="
					+ URLEncoder.encode(contFileUrl, StandardCharsets.UTF_8);
		}

		smsMsg = replaceTemplateTokens(smsMsg, Arrays.asList("공급자상호"), supplierName);
		smsMsg = replaceTemplateTokens(smsMsg, Arrays.asList("거래처명", "고객명"), customerName);
		smsMsg = replaceTemplateTokens(smsMsg, Arrays.asList("계약자명", "계약자"), contractName);
		smsMsg = replaceTemplateTokens(smsMsg, Arrays.asList("주소", "거래처주소"), address);
		smsMsg = replaceTemplateTokens(smsMsg, Arrays.asList("계약일"), contractDate);
		smsMsg = replaceTemplateTokens(smsMsg, Arrays.asList("점검자", "점검원"), inspectorName);
		smsMsg = replaceTemplateTokens(
				smsMsg,
				Arrays.asList(
						"CONT_FILE_URL",
						"PDF_URL",
						"DOWNLOAD_URL",
						"download_url",
						"cont_file_url",
						"계약서URL",
						"계약서링크",
						"계약서다운로드링크",
						"다운로드링크",
						"다운로드 링크",
						"다운링크"),
				contFileUrl);
		smsMsg = replaceTemplateTokens(
				smsMsg,
				Arrays.asList("앱없이보기", "앱없이 보기", "미리보기링크", "미리보기 링크", "preview_url"),
				previewUrl);

		smsNoticesList.put(smsMsgKey, smsMsg);
	}

	private String findSmsMsgKey(Map<String, Object> smsNoticesList) {
		if (smsNoticesList.containsKey("SMS_Msg")) return "SMS_Msg";
		if (smsNoticesList.containsKey("SMS_MSG")) return "SMS_MSG";
		for (String key : smsNoticesList.keySet()) {
			if (key == null) continue;
			String normalized = key.replace("_", "").toLowerCase();
			if ("smsmsg".equals(normalized)) return key;
		}
		return null;
	}

	private String replaceTemplateTokens(String text, List<String> keys, String value) {
		if (text == null || text.isEmpty()) return text;
		String output = text;
		for (String key : keys) {
			if (key == null || key.isEmpty()) continue;
			String escapedKey = Pattern.quote(key);
			output = output.replaceAll("(?i)\\{\\s*" + escapedKey + "\\s*\\}", value);
			output = output.replaceAll("(?i)\\[\\s*" + escapedKey + "\\s*\\]", value);
			output = output.replaceAll("(?i)\\<\\s*" + escapedKey + "\\s*\\>", value);
			output = output.replaceAll("(?i)\\#\\s*" + escapedKey + "\\s*\\#", value);
			output = output.replaceAll("(?i)\\$\\s*" + escapedKey + "\\s*\\$", value);
		}
		return output;
	}

	/*
	 * 저장탱크  조회
	 */
	@GetMapping("/tanks/{area_code}/{anz_cu_code}/{anz_sno}")
	public RestAPIResult getSafetycheckAnSobiTankByAreaCodeAndAnzCuCodeAndAnzSno(
			@PathVariable("area_code") String areaCode,
			@PathVariable("anz_cu_code") String anzCuCode,
			@PathVariable("anz_sno") String anzSno,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get AnSobiTank AreaCode AnzCuCode AnzSno API  : Received data - {}", areaCode, anzCuCode, anzSno);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			AnSobiTankService anSobiTankService = new AnSobiTankService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listResult = anSobiTankService.getAnSobiTankServiceBy(areaCode, anzCuCode, anzSno);
			anSobiTankService.close();

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			String sign = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);
			anSobiSignService.close();

			Map<String, Object> mapResult = new HashMap<String, Object>();
			mapResult.put("data", listResult);
			mapResult.put("sign", sign);

			resultData = mapResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}
	/*
	 * 저장탱크
	 */
	@GetMapping("/tanks/{area_code}/{anz_cu_code}")
	public RestAPIResult getSafetycheckAnSobiTankByAreaCodeAndAnzCuCode(
			@PathVariable("area_code") String areaCode,
			@PathVariable("anz_cu_code") String anzCuCode,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get AnSobiTank AreaCode AnzCuCode API : Received data - {}", areaCode, anzCuCode);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			AnSobiTankService anSobiTankService = new AnSobiTankService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listResult = anSobiTankService.getLastAnSobiTankServiceBy(areaCode, anzCuCode);
			anSobiTankService.close();

			String sign = "";
			if (listResult.isEmpty() == false) {
				String anzSno = (String) listResult.get(0).get("ANZ_Sno");
				AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
				sign = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);
				anSobiSignService.close();
			}

			Map<String, Object> mapResult = new HashMap<String, Object>();
			mapResult.put("data", listResult);
			mapResult.put("sign", sign);

			resultData = mapResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}
	/*
	 * 저장탱크 등록
	 */
	@PostMapping("/tanks")
	public RestAPIResult postAddNewAnSobiTank(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start AddNew AnSobi Tank API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobiTank anSobiTank = parseJsonAnSobiTank(false, jsonData);
			AnSobiTankService anSobiTankService = new AnSobiTankService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiTankService.addNewAnSobiTank(anSobiTank);
			anSobiTankService.close();

			String AnzSNo = (String) mapResult.get("po_ANZ_Sno");

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobiTank.getAreaCode());
			anSobiSign.setAnzCuCode(anSobiTank.getAnzCuCode());
			anSobiSign.setAnzSno(AnzSNo);
			anSobiSign.setAnzDate(anSobiTank.getAnzDate());
			anSobiSign.setAnzId(anSobiTank.getAnzUserId());

			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);

			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);
			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_TRAN_INFO", "E02 소비설비점검 등록오류.");
			}
			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}
	/*
	 * 저장탱크 수정
	 */
	@PutMapping("/tanks")
	public RestAPIResult putUpdateAnSobiTank(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Update AnSobiTank API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobiTank anSobiTank = parseJsonAnSobiTank(false, jsonData);
			AnSobiTankService anSobiTankService = new AnSobiTankService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiTankService.updateAnSobiTank(anSobiTank);
			anSobiTankService.close();

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobiTank.getAreaCode());
			anSobiSign.setAnzCuCode(anSobiTank.getAnzCuCode());
			anSobiSign.setAnzSno(anSobiTank.getAnzSno());
			anSobiSign.setAnzDate(anSobiTank.getAnzDate());
			anSobiSign.setAnzId(anSobiTank.getAnzUserId());

			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);

			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);
			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_TRAN_INFO", "E01 소비설비점검 수정오류.");
			}
			resultData = mapResult;
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}
	/*
	 * 저장탱크 삭제
	 */
	@DeleteMapping("/tanks")
	public RestAPIResult deleteAnSobiTank(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Delete AnSobiTank API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobiTank anSobiTank = parseJsonAnSobiTank(true, jsonData);

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobiTank.getAreaCode());
			anSobiSign.setAnzCuCode(anSobiTank.getAnzCuCode());
			anSobiSign.setAnzSno(anSobiTank.getAnzSno());

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			anSobiSignService.deleteAnSobiSign(anSobiSign);
			anSobiSignService.close();

			AnSobiTankService anSobiTankService = new AnSobiTankService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiTankService.deleteAnSobiTank(anSobiTank);
			anSobiTankService.close();

			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
	 * 소비설비 조회
	 */
	@GetMapping("/saving/{area_code}/{anz_cu_code}/{anz_sno}")
	public RestAPIResult getAnSobiSafeByAreaCodeAndAnzCuCodeAndAnzSno(
			@PathVariable("area_code") String areaCode,
			@PathVariable("anz_cu_code") String anzCuCode,
			@PathVariable("anz_sno") String anzSno,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get AnSobiSafe AreaCode AnzCuCode AnzSno API  : Received data - {}", areaCode, anzCuCode, anzSno);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			AnSobiSafeService anSobiSafeService = new AnSobiSafeService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listResult = anSobiSafeService.getAnSobiSafeServiceBy(areaCode, anzCuCode, anzSno);
			anSobiSafeService.close();

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			String sign = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);
			anSobiSignService.close();

			Map<String, Object> mapResult = new HashMap<String, Object>();
			mapResult.put("data", listResult);
			mapResult.put("sign", sign);

			resultData = mapResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}
	/*
	 * 소비설비 조회
	 */
	@GetMapping("/saving/{area_code}/{anz_cu_code}")
	public RestAPIResult getAnSobiSafeByAreaCodeAndAnzCuCode(
			@PathVariable("area_code") String areaCode,
			@PathVariable("anz_cu_code") String anzCuCode,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get AnSobiSafe AreaCode AnzCuCode API : Received data - {}", areaCode, anzCuCode);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			AnSobiSafeService anSobiSafeService = new AnSobiSafeService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listResult = anSobiSafeService.getLastAnSobiSafeBy(areaCode, anzCuCode);
			anSobiSafeService.close();

			String sign = "";
			if (listResult.isEmpty() == false) {
				String anzSno = (String) listResult.get(0).get("ANZ_Sno");
				AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
				sign = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, anzSno);
				anSobiSignService.close();
			}

			Map<String, Object> mapResult = new HashMap<String, Object>();
			mapResult.put("data", listResult);
			mapResult.put("sign", sign);

			resultData = mapResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}
	/*
	 * 소비설비 등록
	 */
	@PostMapping("/saving")
	public RestAPIResult postAddNewAnSobiSafe(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start AddNew AnSobi Safe API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobiSafe anSobiSafe = parseJsonAnSobiSafe(false, jsonData);
			AnSobiSafeService anSobiSafeService = new AnSobiSafeService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());

			Map<String, Object> mapResult = anSobiSafeService.addNewAnSobiSafe(anSobiSafe);
			anSobiSafeService.close();

			String AnzSNo = (String) mapResult.get("po_ANZ_Sno");

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobiSafe.getAreaCode());
			anSobiSign.setAnzCuCode(anSobiSafe.getAnzCuCode());
			anSobiSign.setAnzSno(AnzSNo);
			anSobiSign.setAnzDate(anSobiSafe.getAnzDate());
			anSobiSign.setAnzId(anSobiSafe.getAnzUserId());

			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);

			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);
			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_TRAN_INFO", "E02 소비설비점검 등록오류.");
			}
			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}
	/*
	 * 소비설비 수정
	 */
	@PutMapping("/saving")
	public RestAPIResult putUpdateAnSobiSafe(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Update AnSobi Safe API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobiSafe anSobiSafe = parseJsonAnSobiSafe(false, jsonData);

			AnSobiSafeService anSobiSafeService = new AnSobiSafeService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiSafeService.updateAnSobiSafe(anSobiSafe);
			anSobiSafeService.close();

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobiSafe.getAreaCode());
			anSobiSign.setAnzCuCode(anSobiSafe.getAnzCuCode());
			anSobiSign.setAnzSno(anSobiSafe.getAnzSno());
			anSobiSign.setAnzDate(anSobiSafe.getAnzDate());
			anSobiSign.setAnzId(anSobiSafe.getAnzUserId());

			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);

			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);
			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_TRAN_INFO", "E01 소비설비점검 수정오류.");
			}

			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}
	/*
	 * 소비설비 삭제
	 */
	@DeleteMapping("/saving")
	public RestAPIResult deleteAnSobiSafe(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Delete AnSobi Safe API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnSobiSafe anSobiSafe = parseJsonAnSobiSafe(true, jsonData);

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anSobiSafe.getAreaCode());
			anSobiSign.setAnzCuCode(anSobiSafe.getAnzCuCode());
			anSobiSign.setAnzSno(anSobiSafe.getAnzSno());

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			anSobiSignService.deleteAnSobiSign(anSobiSign);
			anSobiSignService.close();

			AnSobiSafeService anSobiSafeService = new AnSobiSafeService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anSobiSafeService.deleteAnSobiSafe(anSobiSafe);
			anSobiSafeService.close();

			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
	 * 공급계약 조회
	 */
	@GetMapping("/cont/{area_code}/{anz_cu_code}/{anz_sno}")
	public RestAPIResult getAnContByAreaCodeAndAnzCuCodeAndAnzSno(
			@PathVariable("area_code") String areaCode,
			@PathVariable("anz_cu_code") String anzCuCode,
			@PathVariable("anz_sno") String anzSno,
			@RequestParam("sessionid") Optional<String> optSessionId)
			throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get AnCont AreaCode AnzCuCode AnzSno API  : Received data - {}", areaCode, anzCuCode, anzSno);

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

			AnContService anContService = new AnContService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listResult = anContService.getAnContServiceBy(areaCode, anzCuCode, anzSno);
			anContService.close();

			logger.info("===============================================================");
			logger.info("ListResult, {}, {}, {} ", areaCode, anzCuCode, anzSno);
			logger.info("ListResult,{} ", listResult);
			logger.info("===============================================================");



			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			String sign  = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, "C"+anzSno);
			String sign1 = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, "P"+anzSno);

			anSobiSignService.close();

			Map<String, Object> mapResult = new HashMap<String, Object>();
			mapResult.put("data", listResult);
			mapResult.put("sign", sign);
			mapResult.put("sign1", sign1);

			resultData = mapResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
	 * 공급계약
	 */
	@GetMapping("/cont/{area_code}/{anz_cu_code}")
	public RestAPIResult getAnContByAreaCodeAndAnzCuCode(
			@PathVariable("area_code") String areaCode,
			@PathVariable("anz_cu_code") String anzCuCode,
			@RequestParam("sessionid") Optional<String> optSessionId)
			throws SessionIdNotReceivedException, InvalidSessionIdException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		logger.debug("Start get AnCont AreaCode AnzCuCode API : Received data - {}", areaCode, anzCuCode);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			AnContService anContService = new AnContService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> listResult = anContService.getLastAnContServiceBy(areaCode, anzCuCode);
			anContService.close();

			String sign = "";
			String sign1 = "";

			if (listResult.isEmpty() == false) {
				String anzSno = (String) listResult.get(0).get("ANZ_Sno");
				AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
				sign = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, "C"+anzSno);
				sign1 = anSobiSignService.getSignByAreaCodeAndAnzCuCodeAndAnzSno(areaCode, anzCuCode, "P"+anzSno);
				anSobiSignService.close();
			}

			Map<String, Object> mapResult = new HashMap<String, Object>();
			mapResult.put("data", listResult);
			mapResult.put("sign", sign);
			mapResult.put("sign1", sign1);

			resultData = mapResult;
		}

		RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
	 * 공급게약 등록
	 */
	@PostMapping("/cont")
	public RestAPIResult postAddAnCont(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
			throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Add AnCont  API : Received data - {}", jsonData);



		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// PDF 파일 만들기
			Random random = new Random();
			int length = 15;  // 생성할 문자열의 길이

			StringBuilder randomString = new StringBuilder();

			for (int i = 0; i < length; i++) {
				// 대소문자 알파벳을 포함한 난수 생성
				char randomChar = (char) (random.nextInt(26) + 'a' + (random.nextBoolean() ? 0 : 'A' - 'a'));
				randomString.append(randomChar);
			}


			// Read json data
			AnCont anCont = parseJsonAnCont(false, jsonData);

			fileDownloadController.createPDF(randomString.toString(), anCont);

			String CONT_FILE_URL = "http://gas.joaoffice.com:14013/download/" + randomString.toString() + ".pdf";



			anCont.setContFileUrl(CONT_FILE_URL);
			// 계약서 PDF  만들어 저장 하기..


			AnContService anContService = new AnContService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anContService.createAnCont(anCont);
			anContService.close();

			String AnzSNo = (String) mapResult.get("po_ANZ_Sno");


			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anCont.getAreaCode());
			anSobiSign.setAnzCuCode(anCont.getAnzCuCode());
			anSobiSign.setAnzSno("C" + AnzSNo);
			anSobiSign.setAnzDate(anCont.getAnzDate());
			anSobiSign.setAnzId(anCont.getUserno());

			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);

			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);
			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_CONTRACT_INFO", "E02 공급계약 등록오류.");
			}

			AnSobiSign anSobiSignC = new AnSobiSign();
			anSobiSignC.setAreaCode(anCont.getAreaCode());
			anSobiSignC.setAnzCuCode(anCont.getAnzCuCode());
			anSobiSignC.setAnzSno("P" + AnzSNo);
			anSobiSignC.setAnzDate(anCont.getAnzDate());
			anSobiSignC.setAnzId(anCont.getUserno());

			jsonRootNode = mapper.readTree(jsonData);

			nodeName = "ANZ_Sign_C";
			anSobiSignC.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			AnSobiSignService anSobiSignServiceC = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			intResult = anSobiSignServiceC.saveAnSobiSign(anSobiSignC);
			anSobiSignServiceC.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_CONTRACT_INFO", "E02 공급계약 등록오류.");
			}

			mapResult.put("po_CONT_FILE_URL", CONT_FILE_URL );
			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}


	/*
	 * todo:공급게약 수정
	 *  * todo:공급게약 수정
	 *     * todo:공급게약 수정
	 */
	@PutMapping("/cont")
	public RestAPIResult putUpdateAnCont(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
			throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Update AnCont API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnCont anCont = parseJsonAnCont(false, jsonData);
			AnContService anContService = new AnContService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anContService.updateAnCont(anCont);
			anContService.close();

			AnSobiSign anSobiSign = new AnSobiSign();

			//todo:##################################################1111111-- cusomter인 경우 계약자..
			anSobiSign.setAreaCode(anCont.getAreaCode());
			anSobiSign.setAnzCuCode(anCont.getAnzCuCode());
			anSobiSign.setAnzSno("C"+ anCont.getAnzSno());
			anSobiSign.setAnzDate(anCont.getAnzDate());
			anSobiSign.setAnzId(anCont.getUserno());
			ObjectMapper mapper = new ObjectMapper();
			JsonNode jsonRootNode = mapper.readTree(jsonData);
			String nodeName = "ANZ_Sign";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));
			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult = anSobiSignService.saveAnSobiSign(anSobiSign);


			//todo:##################################################222222 -회사인 경우..
			anSobiSign.setAreaCode(anCont.getAreaCode());
			anSobiSign.setAnzCuCode(anCont.getAnzCuCode());
			anSobiSign.setAnzSno("P"+ anCont.getAnzSno());
			anSobiSign.setAnzDate(anCont.getAnzDate());
			anSobiSign.setAnzId(anCont.getUserno());
			mapper = new ObjectMapper();
			jsonRootNode = mapper.readTree(jsonData);
			nodeName = "ANZ_Sign_C";
			anSobiSign.setAnzSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));
			anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			int intResult2 = anSobiSignService.saveAnSobiSign(anSobiSign);


			anSobiSignService.close();

			if (intResult == 0) {
				mapResult.clear();
				mapResult.put("po_CONTRACT_INFO", "E01 공급계약 수정오류.");
			}
			resultData = mapResult;
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}
	/*
	 * 공금계약 삭제
	 */
	@DeleteMapping("/cont")
	public RestAPIResult deleteAnCont(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
			throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start Delete AnCont API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			AnCont anCont = parseJsonAnCont(true, jsonData);

			AnSobiSign anSobiSign = new AnSobiSign();
			anSobiSign.setAreaCode(anCont.getAreaCode());
			anSobiSign.setAnzCuCode(anCont.getAnzCuCode());
			anSobiSign.setAnzSno(anCont.getAnzSno());

			AnSobiSignService anSobiSignService = new AnSobiSignService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			anSobiSignService.deleteAnSobiSign(anSobiSign);
			anSobiSignService.close();

			AnContService anContService = new AnContService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> mapResult = anContService.deleteAnCont(anCont);
			anContService.close();

			resultData = mapResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
	 * 안전 검침 현황
	 * 2019.12.12 수정 - SAFE_CD, APP_User 추가
	 */
	@PostMapping("/status/search/keyword")
	public RestAPIResult postSafetycheckStatusSearchKeyword(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start get Safetycheck Status Search Keyword API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			SafeInsertList safeInsertList = parseJsonSafetySafeInsertList(false, jsonData);
			String orderBy = safeInsertList.getOrderBy();

			SafeInsertListService safeInsertListService = new SafeInsertListService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());

			if (orderBy.isEmpty() == true) {
				List<Map<String, Object>> listResult = safeInsertListService.getSafeInsertListServiceBy(safeInsertList);
				resultData = listResult;
			}
			else {
				List<Map<String, Object>> listResult = safeInsertListService.getSafeInsertListServiceByOrderBy(safeInsertList);
				resultData = listResult;
			}
			safeInsertListService.close();
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
	 * 안전 검침 현황
	 * 2019.12.12 수정 - SAFE_CD, APP_User 추가
	 */
	@PostMapping("/status/search/location")
	public RestAPIResult postSafetycheckStatusSearchLocation(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start get Safetycheck Status Search Location API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			// Read json data
			SafeInsertList safeInsertList = parseJsonSafetySafeInsertList(true, jsonData);
			String orderBy = safeInsertList.getOrderBy();

			SafeInsertListService safeInsertListService = new SafeInsertListService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			if (orderBy.isEmpty() == true) {
				List<Map<String, Object>> listResult = safeInsertListService.getGpsSafeInsertListeServiceBy(safeInsertList);
				resultData = listResult;
			}
			else {
				List<Map<String, Object>> listResult = safeInsertListService.getGpsSafeInsertListeServiceByOrderBy(safeInsertList);
				resultData = listResult;
			}

			safeInsertListService.close();

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	private SafetyCustomer parseJsonSafetyCustomerInfo(boolean isLocationInfoExist, String jsonCustomerData)
			throws JsonNodeNotFoundException, IOException {

		SafetyCustomer safetyCustomer = new SafetyCustomer();

		// Read json data
		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonCustomerData);

		String nodeName = "AREA_CODE";
		safetyCustomer.setAreaCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "FIND_STR";
		safetyCustomer.setFindStr(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "SAFE_FLAN";
		safetyCustomer.setSafeFlan(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_TYPE";
		safetyCustomer.setCuType(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_CODE";
		safetyCustomer.setCuCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "APT_CD";
		safetyCustomer.setAptCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "SW_CD";
		safetyCustomer.setSwCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "MAN_CD";
		safetyCustomer.setManCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "JY_CD";
		safetyCustomer.setJyCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ADDR_TEXT";
		safetyCustomer.setAddrText(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "SUPP_YN";
		safetyCustomer.setSuppYN(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "Conformity_YN";
		safetyCustomer.setConformityYN(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		if (isLocationInfoExist == true) {
			nodeName = "GPS_X";
			safetyCustomer.setGpsX(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_Y";
			safetyCustomer.setGpsY(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));
		}

		nodeName = "OrderBy";
		safetyCustomer.setOrderBy(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		return safetyCustomer;
	}
	private AnCont parseJsonAnCont(boolean isDelete, String jsonData)
			throws JsonNodeNotFoundException, IOException {
		AnCont anCont = new AnCont();

		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonData);

		String nodeName = "AREA_CODE";
		anCont.setAreaCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ANZ_Cu_Code";
		anCont.setAnzCuCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ANZ_Sno";
		anCont.setAnzSno(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));


		if (isDelete == false) {

			nodeName = "ANZ_Date";
			anCont.setAnzDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Date_F";
			anCont.setAnzDateF(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Date_T";
			anCont.setAnzDateT(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "SALE_TYPE";
			anCont.setSaleType(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CONT_TYPE";
			anCont.setContType(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USE_CYL";
			anCont.setUseCyl(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USE_CYL_MEMO";
			anCont.setUseCylMemo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USE_METER";
			anCont.setUseMeter(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USE_METER_MEMO";
			anCont.setUseMeterMemo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USE_TRANS";
			anCont.setUseTrans(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USE_TRANS_MEMO";
			anCont.setUseTransMemo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USE_VAPOR";
			anCont.setUseVapor(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USE_VAPOR_MEMO";
			anCont.setUseVaporMemo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USE_PIPE";
			anCont.setUsePipe(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USE_PIPE_MEMO";
			anCont.setUsePipeMemo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USE_Facility";
			anCont.setUseFacility(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));



			nodeName = "CENTER_SI";
			anCont.setCenterSi(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CENTER_Consumer";
			anCont.setCenterConsumer(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CENTER_KGS";
			anCont.setCenterKgs(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CENTER_GAS";
			anCont.setCenterGas(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "COM_BEFORE";
			anCont.setComBefore(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "COM_NO";
			anCont.setComNo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "COM_NAME";
			anCont.setComName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "COM_TEL";
			anCont.setComTel(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "COM_HP";
			anCont.setComHp(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "COM_CEO_NAME";
			anCont.setComCeoName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "COM_SIGN_YN";
			anCont.setComSignYn(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CU_GONGNO";
			anCont.setCuGongno(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CUST_COM_NO";
			anCont.setCustComNo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CUST_COM_NAME";
			anCont.setCustComName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CU_ADDR1";
			anCont.setCuAddr1(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CU_ADDR2";
			anCont.setCuAddr2(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CUST_TEL";
			anCont.setCustTel(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CU_GONGNAME";
			anCont.setCuGongName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CUST_SIGN";
			anCont.setCustSign(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CONT_FILE_URL";
			anCont.setContFileUrl(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_Confirm_TEL";
			anCont.setAnzCuConfirmTel(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_SMS_YN";
			anCont.setAnzCuSmsYn(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));


			nodeName = "REG_DT";
			anCont.setRegDt(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "REG_USER_ID";
			anCont.setRegUserId(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "REG_SW_CODE";
			anCont.setRegSwCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "REG_SW_NAME";
			anCont.setRegSwName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "USERNO";
			anCont.setUserno(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_X";
			anCont.setGpsX(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_Y";
			anCont.setGpsY(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "REG_TYPE";
			anCont.setRegType(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		}


		return anCont;
	}

	private AnSobi parseJsonAnSobi(boolean isDelete, String jsonData)
			throws JsonNodeNotFoundException, IOException {

		AnSobi anSobi = new AnSobi();

		// Read json data
		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonData);

		String nodeName = "AREA_CODE";
		anSobi.setAreaCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ANZ_Cu_Code";
		anSobi.setAnzCuCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ANZ_Sno";
		anSobi.setAnzSno(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		if (isDelete == false) {
			nodeName = "ANZ_Date";
			anSobi.setAnzDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_SW_Code";
			anSobi.setAnzSwCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_SW_Name";
			anSobi.setAnzSwName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CustName";
			anSobi.setAnzCustName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Tel";
			anSobi.setAnzTel(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "Zip_Code";
			anSobi.setZipCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CU_ADDR1";
			anSobi.setCuAddr1(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CU_ADDR2";
			anSobi.setCuAddr2(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_A_01";
			anSobi.setAnzA01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_A_02";
			anSobi.setAnzA02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_A_03";
			anSobi.setAnzA03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_A_04";
			anSobi.setAnzA04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_A_05";
			anSobi.setAnzA05(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_B_01";
			anSobi.setAnzB01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_B_02";
			anSobi.setAnzB02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_B_03";
			anSobi.setAnzB03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_B_04";
			anSobi.setAnzB04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_B_05";
			anSobi.setAnzB05(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_01";
			anSobi.setAnzC01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_02";
			anSobi.setAnzC02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_03";
			anSobi.setAnzC03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_04";
			anSobi.setAnzC04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_05";
			anSobi.setAnzC05(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_06";
			anSobi.setAnzC06(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_07";
			anSobi.setAnzC07(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_08";
			anSobi.setAnzC08(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gita_01";
			anSobi.setAnzGita01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_D_01";
			anSobi.setAnzD01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_D_02";
			anSobi.setAnzD02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_D_03";
			anSobi.setAnzD03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_D_04";
			anSobi.setAnzD04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_D_05";
			anSobi.setAnzD05(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_E_01";
			anSobi.setAnzE01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_E_02";
			anSobi.setAnzE02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_E_03";
			anSobi.setAnzE03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_E_04";
			anSobi.setAnzE04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_F_01";
			anSobi.setAnzF01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_F_02";
			anSobi.setAnzF02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_F_03";
			anSobi.setAnzF03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_F_04";
			anSobi.setAnzF04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_01";
			anSobi.setAnzG01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_02";
			anSobi.setAnzG02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_03";
			anSobi.setAnzG03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_04";
			anSobi.setAnzG04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_05";
			anSobi.setAnzG05(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_06";
			anSobi.setAnzG06(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_07";
			anSobi.setAnzG07(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_08";
			anSobi.setAnzG08(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gita_02";
			anSobi.setAnzGita02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Ga";
			anSobi.setAnzGa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Na";
			anSobi.setAnzNa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Da";
			anSobi.setAnzDa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Ra";
			anSobi.setAnzRa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Ma";
			anSobi.setAnzMa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Ba";
			anSobi.setAnzBa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Sa";
			anSobi.setAnzSa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_AA";
			anSobi.setAnzAa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Ja";
			anSobi.setAnzJa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Cha_IN";
			anSobi.setAnzChaIn(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Cha";
			anSobi.setAnzCha(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Car";
			anSobi.setAnzCar(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gae_01";
			anSobi.setAnzGae01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gae_02";
			anSobi.setAnzGae02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gae_03";
			anSobi.setAnzGae03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gae_04";
			anSobi.setAnzGae04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_GongDate";
			anSobi.setAnzGongDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_Confirm";
			anSobi.setAnzCuConfirm(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_Confirm_TEL";
			anSobi.setAnzCuConfirmTel(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_SMS_YN";
			anSobi.setAnzCuSmsYn(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_GongNo";
			anSobi.setAnzGongNo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_GongName";
			anSobi.setAnzGongName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Sign_YN";
			anSobi.setAnzSignYn(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_X";
			anSobi.setGpsX(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_Y";
			anSobi.setGpsY(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "APP_User";
			anSobi.setAppUser(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));
		}

		return anSobi;
	}
	/*
	 * 소비설비
	 */
	private AnSobi parseJsonAnSobiNew(boolean isDelete, String jsonData)
			throws JsonNodeNotFoundException, IOException {

		AnSobi anSobi = new AnSobi();

		// Read json data
		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonData);

		String nodeName = "AREA_CODE";
		anSobi.setAreaCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ANZ_Cu_Code";
		anSobi.setAnzCuCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ANZ_Sno";
		anSobi.setAnzSno(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		if (isDelete == false) {
			nodeName = "ANZ_Date";
			anSobi.setAnzDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_SW_Code";
			anSobi.setAnzSwCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_SW_Name";
			anSobi.setAnzSwName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CustName";
			anSobi.setAnzCustName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Tel";
			anSobi.setAnzTel(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "Zip_Code";
			anSobi.setZipCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CU_ADDR1";
			anSobi.setCuAddr1(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CU_ADDR2";
			anSobi.setCuAddr2(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_A_01";
			anSobi.setAnzA01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_A_02";
			anSobi.setAnzA02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_A_03";
			anSobi.setAnzA03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_A_04";
			anSobi.setAnzA04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_A_05";
			anSobi.setAnzA05(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_B_01";
			anSobi.setAnzB01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_B_02";
			anSobi.setAnzB02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_B_03";
			anSobi.setAnzB03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_B_04";
			anSobi.setAnzB04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_B_05";
			anSobi.setAnzB05(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_01";
			anSobi.setAnzC01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_02";
			anSobi.setAnzC02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_03";
			anSobi.setAnzC03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_04";
			anSobi.setAnzC04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_05";
			anSobi.setAnzC05(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_06";
			anSobi.setAnzC06(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_07";
			anSobi.setAnzC07(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_C_08";
			anSobi.setAnzC08(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gita_01";
			anSobi.setAnzGita01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_D_01";
			anSobi.setAnzD01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_D_02";
			anSobi.setAnzD02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_D_03";
			anSobi.setAnzD03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_D_04";
			anSobi.setAnzD04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_D_05";
			anSobi.setAnzD05(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_E_01";
			anSobi.setAnzE01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_E_02";
			anSobi.setAnzE02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_E_03";
			anSobi.setAnzE03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_E_04";
			anSobi.setAnzE04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_F_01";
			anSobi.setAnzF01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_F_02";
			anSobi.setAnzF02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_F_03";
			anSobi.setAnzF03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_F_04";
			anSobi.setAnzF04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_01";
			anSobi.setAnzG01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_02";
			anSobi.setAnzG02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_03";
			anSobi.setAnzG03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_04";
			anSobi.setAnzG04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_05";
			anSobi.setAnzG05(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_06";
			anSobi.setAnzG06(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_07";
			anSobi.setAnzG07(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_G_08";
			anSobi.setAnzG08(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gita_02";
			anSobi.setAnzGita02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Ga";
			anSobi.setAnzGa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Na";
			anSobi.setAnzNa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Da";
			anSobi.setAnzDa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Ra";
			anSobi.setAnzRa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Ma";
			anSobi.setAnzMa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Ba";
			anSobi.setAnzBa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Sa";
			anSobi.setAnzSa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_AA";
			anSobi.setAnzAa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Ja";
			anSobi.setAnzJa(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Cha_IN";
			anSobi.setAnzChaIn(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Cha";
			anSobi.setAnzCha(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Car";
			anSobi.setAnzCar(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gae_01";
			anSobi.setAnzGae01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gae_02";
			anSobi.setAnzGae02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gae_03";
			anSobi.setAnzGae03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Gae_04";
			anSobi.setAnzGae04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_GongDate";
			anSobi.setAnzGongDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_Confirm";
			anSobi.setAnzCuConfirm(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_Confirm_TEL";
			anSobi.setAnzCuConfirmTel(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_SMS_YN";
			anSobi.setAnzCuSmsYn(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_GongNo";
			anSobi.setAnzGongNo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_GongName";
			anSobi.setAnzGongName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Sign_YN";
			anSobi.setAnzSignYn(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_X";
			anSobi.setGpsX(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_Y";
			anSobi.setGpsY(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "APP_User";
			anSobi.setAppUser(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Finish_DATE";
			anSobi.setAnzFinishDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Circuit_DATE";
			anSobi.setAnzCircuitDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		}

		return anSobi;
	}

	/*
	 * 저장탱크
	 */
	private AnSobiTank parseJsonAnSobiTank(boolean isDelete, String jsonData)
			throws JsonNodeNotFoundException, IOException {

		AnSobiTank anSobiTank = new AnSobiTank();

		// Read json data
		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonData);

		String nodeName = "AREA_CODE";
		anSobiTank.setAreaCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ANZ_Cu_Code";
		anSobiTank.setAnzCuCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ANZ_Sno";
		anSobiTank.setAnzSno(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		if (isDelete == false) {
			nodeName = "ANZ_Date";
			anSobiTank.setAnzDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_SW_Code";
			anSobiTank.setAnzSwCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_SW_Name";
			anSobiTank.setAnzSwName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_KG_01";
			anSobiTank.setAnzTankKg01(GasMaxUtility.parseJsonNodeToDouble(jsonRootNode, nodeName).floatValue());

			nodeName = "ANZ_TANK_KG_02";
			anSobiTank.setAnzTankKg02(GasMaxUtility.parseJsonNodeToDouble(jsonRootNode, nodeName).floatValue());

			nodeName = "ANZ_TANK_01";
			anSobiTank.setAnzTank01(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_01_Bigo";
			anSobiTank.setAnzTank01Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_02";
			anSobiTank.setAnzTank02(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_02_Bigo";
			anSobiTank.setAnzTank02Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_03";
			anSobiTank.setAnzTank03(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_03_Bigo";
			anSobiTank.setAnzTank03Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_04";
			anSobiTank.setAnzTank04(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_04_Bigo";
			anSobiTank.setAnzTank04Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_05";
			anSobiTank.setAnzTank05(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_05_Bigo";
			anSobiTank.setAnzTank05Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_06";
			anSobiTank.setAnzTank06(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_06_Bigo";
			anSobiTank.setAnzTank06Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_07";
			anSobiTank.setAnzTank07(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_07_Bigo";
			anSobiTank.setAnzTank07Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_08";
			anSobiTank.setAnzTank08(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_08_Bigo";
			anSobiTank.setAnzTank08Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_09";
			anSobiTank.setAnzTank09(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_09_Bigo";
			anSobiTank.setAnzTank09Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Check_item_10";
			anSobiTank.setAnzcheckItem10(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_10";
			anSobiTank.setAnzTank10(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_10_Bigo";
			anSobiTank.setAnzTank10Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Check_item_11";
			anSobiTank.setAnzcheckItem11(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_11";
			anSobiTank.setAnzTank11(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_11_Bigo";
			anSobiTank.setAnzTank11Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Check_item_12";
			anSobiTank.setAnzcheckItem12(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_12";
			anSobiTank.setAnzTank12(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_12_Bigo";
			anSobiTank.setAnzTank12Bigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_SW_Bigo1";
			anSobiTank.setAnzTankSwBigo1(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_TANK_SW_Bigo2";
			anSobiTank.setAnzTankSwBigo2(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CustName";
			anSobiTank.setAnzCustName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Sign_YN";
			anSobiTank.setAnzSignYn(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_Confirm";
			anSobiTank.setAnzCuConfirm(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_Confirm_TEL";
			anSobiTank.setAnzCuConfirmTel(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_X";
			anSobiTank.setGpsX(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_Y";
			anSobiTank.setGpsY(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_User_ID";
			anSobiTank.setAnzUserId(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));
		}

		return anSobiTank;
	}

	private AnSobiSafe parseJsonAnSobiSafe(boolean isDelete, String jsonData)
			throws JsonNodeNotFoundException, IOException {

		AnSobiSafe anSobiSafe = new AnSobiSafe();

		// Read json data
		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonData);

		String nodeName = "AREA_CODE";
		anSobiSafe.setAreaCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ANZ_Cu_Code";
		anSobiSafe.setAnzCuCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ANZ_Sno";
		anSobiSafe.setAnzSno(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		if (isDelete == false) {
			nodeName = "ANZ_Date";
			anSobiSafe.setAnzDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_SW_Code";
			anSobiSafe.setAnzSwCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_SW_Name";
			anSobiSafe.setAnzSwName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_LP_KG_01";
			anSobiSafe.setAnzLpKg01(GasMaxUtility.parseJsonNodeToDouble(jsonRootNode, nodeName).floatValue());

			nodeName = "ANZ_LP_KG_02";
			anSobiSafe.setAnzLpKg02(GasMaxUtility.parseJsonNodeToDouble(jsonRootNode, nodeName).floatValue());

			nodeName = "ANZ_Item1";
			anSobiSafe.setAnzItem1(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item1_SUB";
			anSobiSafe.setAnzItem1Sub(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item1_Text";
			anSobiSafe.setAnzItem1Text(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item2";
			anSobiSafe.setAnzItem2(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item2_SUB";
			anSobiSafe.setAnzItem2Sub(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item3";
			anSobiSafe.setAnzItem3(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item3_SUB";
			anSobiSafe.setAnzItem3Sub(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item3_Text";
			anSobiSafe.setAnzItem3Text(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item4";
			anSobiSafe.setAnzItem4(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item4_SUB";
			anSobiSafe.setAnzItem4Sub(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item5";
			anSobiSafe.setAnzItem5(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item5_SUB";
			anSobiSafe.setAnzItem5Sub(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item5_Text";
			anSobiSafe.setAnzItem5Text(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item6";
			anSobiSafe.setAnzItem6(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item6_SUB";
			anSobiSafe.setAnzItem6Sub(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item7";
			anSobiSafe.setAnzItem7(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item7_SUB";
			anSobiSafe.setAnzItem7Sub(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item8";
			anSobiSafe.setAnzItem8(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item8_SUB";
			anSobiSafe.setAnzItem8Sub(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item8_Text";
			anSobiSafe.setAnzItem8Text(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item9";
			anSobiSafe.setAnzItem9(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item9_SUB";
			anSobiSafe.setAnzItem9Sub(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item9_Text1";
			anSobiSafe.setAnzItem9Text1(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item9_Text2";
			anSobiSafe.setAnzItem9Text2(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item10";
			anSobiSafe.setAnzItem10(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item10_Text1";
			anSobiSafe.setAnzItem10Text1(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Item10_Text2";
			anSobiSafe.setAnzItem10Text2(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_Confirm";
			anSobiSafe.setAnzCuConfirm(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_CU_Confirm_TEL";
			anSobiSafe.setAnzCuConfirmTel(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_Sign_YN";
			anSobiSafe.setAnzSignYn(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_X";
			anSobiSafe.setGpsX(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_Y";
			anSobiSafe.setGpsY(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "ANZ_User_ID";
			anSobiSafe.setAnzUserId(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));
		}

		return anSobiSafe;
	}

	private SafeInsertList parseJsonSafetySafeInsertList(boolean isLocationInfoExist, String jsonCustomerData)
			throws JsonNodeNotFoundException, IOException {

		SafeInsertList safeInsertList = new SafeInsertList();

		// Read json data
		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonCustomerData);

		String nodeName = "AREA_CODE";
		safeInsertList.setAreaCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "FIND_STR";
		safeInsertList.setFindStr(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "GUM_DATE_F";
		safeInsertList.setGumDateF(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "GUM_DATE_T";
		safeInsertList.setGumDateT(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_TYPE";
		safeInsertList.setCuType(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_CODE";
		safeInsertList.setCuCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "APT_CD";
		safeInsertList.setAptCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "SW_CD";
		safeInsertList.setSwCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "MAN_CD";
		safeInsertList.setManCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "JY_CD";
		safeInsertList.setJyCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ADDR_TEXT";
		safeInsertList.setAddrText(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "SUPP_YN";
		safeInsertList.setSuppYN(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "Conformity_YN";
		safeInsertList.setConformityYN(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		if (isLocationInfoExist == true) {
			nodeName = "GPS_X";
			safeInsertList.setGpsX(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_Y";
			safeInsertList.setGpsY(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));
		}

		nodeName = "SAFE_CD";
		safeInsertList.setSafeCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "APP_User";
		safeInsertList.setAppUser(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "OrderBy";
		safeInsertList.setOrderBy(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		return safeInsertList;
	}



}
