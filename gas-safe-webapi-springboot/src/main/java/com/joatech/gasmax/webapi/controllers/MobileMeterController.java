package com.joatech.gasmax.webapi.controllers;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

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
import com.joatech.gasmax.webapi.domains.AppUserSafe;
import com.joatech.gasmax.webapi.domains.CustomerMeterInfo;
import com.joatech.gasmax.webapi.domains.MeterCheckStatusInfo;
import com.joatech.gasmax.webapi.domains.MeterCustomer;
import com.joatech.gasmax.webapi.domains.RestAPIResult;
import com.joatech.gasmax.webapi.domains.SaveMeterValue;
import com.joatech.gasmax.webapi.exceptions.InvalidSessionIdException;
import com.joatech.gasmax.webapi.exceptions.JsonNodeNotFoundException;
import com.joatech.gasmax.webapi.exceptions.SessionIdNotReceivedException;
import com.joatech.gasmax.webapi.services.ComboBoxSectionKeywordService;
import com.joatech.gasmax.webapi.services.ComboBoxTypeService;
import com.joatech.gasmax.webapi.services.MeterCustomerService;
import com.joatech.gasmax.webapi.services.UserSessionService;

import utilities.GasMaxUtility;

/*
 * 모바일 검침
 */
@RestController
@RequestMapping("/gas/api/meters")
public class MobileMeterController {

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
	 * todo: 개선 버전----> 거래처 정보 조건 조회
	 */
	@GetMapping("/customers/search/conditions/{area_code}")
	public RestAPIResult getMeterSearchConditionByAreaCode(
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

		logger.info("[Start] getMeterSearchConditionByAreaCode - areaCode={}", areaCode);

		ComboBoxTypeService comboBoxTypeService = new ComboBoxTypeService(
				appUserSafe.getServerIp(),
				Integer.parseInt(appUserSafe.getServerPort()),
				appUserSafe.getServerDBName(),
				appUserSafe.getServerUser(),
				appUserSafe.getServerPassword()
		);

		ComboBoxSectionKeywordService comboKeywordService = new ComboBoxSectionKeywordService(
				appUserSafe.getServerIp(),
				Integer.parseInt(appUserSafe.getServerPort()),
				appUserSafe.getServerDBName(),
				appUserSafe.getServerUser(),
				appUserSafe.getServerPassword()
		);
		try {
			CompletableFuture<List<Map<String, Object>>> futureGubunGumm = CompletableFuture.supplyAsync(() -> comboBoxTypeService.getComboTypeListByTypeAndAreaCode("GUMM", areaCode));
			CompletableFuture<List<Map<String, Object>>> futureGubunSW = CompletableFuture.supplyAsync(() -> comboBoxTypeService.getComboTypeListByTypeAndAreaCode("SW", areaCode));
			CompletableFuture<List<Map<String, Object>>> futureGubunMan = CompletableFuture.supplyAsync(() -> comboBoxTypeService.getComboTypeListByTypeAndAreaCode("MAN", areaCode));
			CompletableFuture<List<Map<String, Object>>> futureGubunJY = CompletableFuture.supplyAsync(() -> comboBoxTypeService.getComboTypeListByTypeAndAreaCode("JY", areaCode));
			CompletableFuture<List<Map<String, Object>>> futureGubunSort = CompletableFuture.supplyAsync(() -> comboBoxTypeService.getComboTypeListByTypeAndAreaCode("SORT", areaCode));
			CompletableFuture<List<Map<String, Object>>> futureGubunMLR = CompletableFuture.supplyAsync(() -> comboBoxTypeService.getComboTypeListByTypeAndAreaCode("M-LR", areaCode));
			CompletableFuture<List<Map<String, Object>>> futureGubunMTY = CompletableFuture.supplyAsync(() -> comboBoxTypeService.getComboTypeListByTypeAndAreaCode("M-TY", areaCode));

			CompletableFuture<List<Map<String, Object>>> futureApt = CompletableFuture.supplyAsync(() -> comboKeywordService.getAllComboAptListByAreaCode(areaCode));
			CompletableFuture<List<Map<String, Object>>> futureGum = CompletableFuture.supplyAsync(() -> comboKeywordService.getAllComboGumListByAreaCode(areaCode));
			CompletableFuture<List<Map<String, Object>>> futureMeter = CompletableFuture.supplyAsync(() -> comboKeywordService.getAllComboMeterListByAreaCode(areaCode));

			CompletableFuture.allOf(
					futureGubunGumm, futureGubunSW, futureGubunMan, futureGubunJY, futureGubunSort,
					futureGubunMLR, futureGubunMTY, futureApt, futureGum, futureMeter
			).join();

			Map<String, Object> mapResult = new HashMap<>();
			mapResult.put("GUMM", futureGubunGumm.get());
			mapResult.put("APT", futureApt.get());
			mapResult.put("SW", futureGubunSW.get());
			mapResult.put("MAN", futureGubunMan.get());
			mapResult.put("JY", futureGubunJY.get());
			mapResult.put("SORT", futureGubunSort.get());
			mapResult.put("GUM", futureGum.get());
			mapResult.put("METER", futureMeter.get());
			mapResult.put("M-LR", futureGubunMLR.get());
			mapResult.put("M-TY", futureGubunMTY.get());
			logger.info("[Complete] getMeterSearchConditionByAreaCode - areaCode={}", areaCode);
			return new RestAPIResult(GasMaxErrors.ERROR_OK, GasMaxErrors.ERROR_CODE_OK, mapResult);

		} catch (InterruptedException | ExecutionException e) {
			logger.error("[Error] getMeterSearchConditionByAreaCode", e);
			throw new RuntimeException(e);
		} finally {
			comboBoxTypeService.close();
			comboKeywordService.close();
		}
	}

	@PostMapping("/customers/search/keyword")
	public RestAPIResult postMeterSearchKeyword(
			@RequestBody String jsonMeterSearchKeywordData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start get meter customer search keyword API : Received data - {}", jsonMeterSearchKeywordData);

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
			MeterCustomer meterCustomerInfo = parseJsonMeterCustomerInfo(false, jsonMeterSearchKeywordData);

			MeterCustomerService meterCustomerService = new MeterCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> meterCustomerKeywordResult = meterCustomerService.getAllSearchMeterCustomerListBy(meterCustomerInfo);

			meterCustomerService.close();
			resultData = meterCustomerKeywordResult;

		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@PostMapping("/customers/search/keyword/sno/{sno}")
	public RestAPIResult postMeterSearchKeywordSno(
			@PathVariable("sno") String sno,
			@RequestBody String jsonMeterSearchKeywordData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start get meter customer search keyword sno API : Received data - {}", jsonMeterSearchKeywordData);

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
			MeterCustomer meterCustomerInfo = parseJsonMeterCustomerInfo(false, jsonMeterSearchKeywordData);

			if (sno.equals(meterCustomerInfo.getGumYMSNo()) == true) {
				MeterCustomerService meterCustomerService = new MeterCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
				List<Map<String, Object>> meterCustomerKeywordResult = meterCustomerService.getSNoSearchMeterCustomerListBy(meterCustomerInfo);
				meterCustomerService.close();
				resultData = meterCustomerKeywordResult;
			} else {
				result = GasMaxErrors.ERROR_DATA_NOT_MATCHED + " SNO";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_MATCHED;
			}
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@PostMapping("/customers/search/keyword/term/{term}")
	public RestAPIResult postMeterSearchKeywordTerm(
			@PathVariable("term") String term,
			@RequestBody String jsonMeterSearchKeywordData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start get meter customer search keyword term API : Received data - {}", jsonMeterSearchKeywordData);

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
			MeterCustomer meterCustomerInfo = parseJsonMeterCustomerInfo(false, jsonMeterSearchKeywordData);

			if (term.equals(meterCustomerInfo.getGumTerm()) == true) {
				MeterCustomerService meterCustomerService = new MeterCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
				List<Map<String, Object>> meterCustomerKeywordResult = meterCustomerService.getTurmSearchMeterCustomerListBy(meterCustomerInfo);
				meterCustomerService.close();
				resultData = meterCustomerKeywordResult;
			} else {
				result = GasMaxErrors.ERROR_DATA_NOT_MATCHED + " TERM";
				resultCode = GasMaxErrors.ERROR_CODE_DATA_NOT_MATCHED;
			}
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@PostMapping("/customers/search/location")
	public RestAPIResult postMeterSearchLocation(
			@RequestBody String jsonMeterSearchKeywordData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start get meter customer search location API : Received data - {}", jsonMeterSearchKeywordData);

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
			MeterCustomer meterCustomerInfo = parseJsonMeterCustomerInfo(true, jsonMeterSearchKeywordData);

			MeterCustomerService meterCustomerService = new MeterCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> meterCustomerKeywordResult = meterCustomerService.getGpsSearchMeterCustomerListBy(meterCustomerInfo);
			meterCustomerService.close();
			resultData = meterCustomerKeywordResult;
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@PostMapping("/customers")
	public RestAPIResult addNewMeterValue (
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, JsonNodeNotFoundException, IOException {

		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start add new meter value API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			SaveMeterValue saveMeterValue = parseJsonSaveMeterValue(false, jsonData);

			MeterCustomerService meterCustomerService = new MeterCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> saveMeterResult = meterCustomerService.addNewSaveMeterValue(saveMeterValue);
			meterCustomerService.close();
			resultData = saveMeterResult;
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	@PutMapping("/customers")
	public RestAPIResult updateMeterValue (
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, JsonNodeNotFoundException, IOException {

		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start update meter value API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			SaveMeterValue saveMeterValue = parseJsonSaveMeterValue(false, jsonData);

			MeterCustomerService meterCustomerService = new MeterCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> saveMeterResult = meterCustomerService.updateSaveMeterValue(saveMeterValue);
			meterCustomerService.close();
			resultData = saveMeterResult;
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}


	@DeleteMapping("/customers")
	public RestAPIResult deleteMeterValue (
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, JsonNodeNotFoundException, IOException {

		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start delete meter value API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			SaveMeterValue saveMeterValue = parseJsonSaveMeterValue(true, jsonData);

			MeterCustomerService meterCustomerService = new MeterCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> saveMeterResult = meterCustomerService.deleteSaveMeterValue(saveMeterValue);
			meterCustomerService.close();
			resultData = saveMeterResult;
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}


	@PutMapping("/info")
	public RestAPIResult updateMeterInfo (
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, JsonNodeNotFoundException, IOException {

		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start update meter info API : Received data - {}", jsonData);

		if (optSessionId.isPresent() == false) {
			throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
		}
		else {
			String sessionId = optSessionId.get();
			AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
			if (appUserSafe == null) {
				throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
			}

			CustomerMeterInfo customerMeterInfo = parseJsonCustomerMeterInfo(jsonData);

			MeterCustomerService meterCustomerService = new MeterCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			Map<String, Object> updateMeterResult = meterCustomerService.updateCustomerMeterInfo(customerMeterInfo);
			meterCustomerService.close();
			resultData = updateMeterResult;
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
	 * 모바일 검침 현황
	 * 2019.12.12 수정 - SAFE_CD, APP_User 추가
	 */
	@PostMapping("/checkstatus/search/keyword")
	public RestAPIResult postCheckStatusSearchKeyword(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start get meter check status search keyword API : Received data - {}", jsonData);

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
			MeterCheckStatusInfo meterCheckStatusInfo = parseJsonMeterCheckStatusInfo(false, jsonData);

			MeterCustomerService meterCustomerService = new MeterCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> meterCustomerKeywordResult = meterCustomerService.getMeterCheckStatusListBy(meterCheckStatusInfo);
			meterCustomerService.close();
			resultData = meterCustomerKeywordResult;
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	/*
	 * 모바일 검침 현황
	 * 2019.12.12 수정 - SAFE_CD, APP_User 추가
	 */
	@PostMapping("/checkstatus/search/location")
	public RestAPIResult postCheckStatusSearchLocation(
			@RequestBody String jsonData,
			@RequestParam("sessionid") Optional<String> optSessionId)
					throws SessionIdNotReceivedException, InvalidSessionIdException, IOException {
		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";
		RestAPIResult apiResult = null;

		logger.debug("Start get meter check status search location API : Received data - {}", jsonData);

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
			MeterCheckStatusInfo meterCheckStatusInfo = parseJsonMeterCheckStatusInfo(true, jsonData);

			MeterCustomerService meterCustomerService = new MeterCustomerService(appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			List<Map<String, Object>> meterCustomerKeywordResult = meterCustomerService.getGpsMeterCheckStatusListBy(meterCheckStatusInfo);
			meterCustomerService.close();
			resultData = meterCustomerKeywordResult;
		}

		apiResult = new RestAPIResult(result, resultCode, resultData);
		return apiResult;
	}

	private MeterCustomer parseJsonMeterCustomerInfo(boolean isLocationInfoExist, String jsonCustomerData)
		throws JsonNodeNotFoundException, IOException {

		MeterCustomer meterCustomer = new MeterCustomer();

		// Read json data
		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonCustomerData);

		String nodeName = "AREA_CODE";
		meterCustomer.setAreaCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "FIND_STR";
		meterCustomer.setFindStr(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "GUM_Date";
		meterCustomer.setGumDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "SUPP_YN";
		meterCustomer.setSuppYN(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "GUM_YMSNO";
		meterCustomer.setGumYMSNo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "GUM_TURM";
		meterCustomer.setGumTerm(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "GUM_MMDD";
		meterCustomer.setGumMMDD(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_CODE";
		meterCustomer.setCuCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "APT_CD";
		meterCustomer.setAptCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "SW_CD";
		meterCustomer.setSwCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "MAN_CD";
		meterCustomer.setManCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "JY_CD";
		meterCustomer.setJyCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ADDR_TEXT";
		meterCustomer.setAddrText(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "SMART_METER_YN";
		meterCustomer.setSmartMeterYN(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		if (isLocationInfoExist == true) {
			nodeName = "GPS_X";
			meterCustomer.setGpsX(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_Y";
			meterCustomer.setGpsY(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));
		}

		nodeName = "OrderBy";
		meterCustomer.setOrderBy(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		return meterCustomer;
	}

	private SaveMeterValue parseJsonSaveMeterValue(boolean isDelete, String jsonData)
			throws JsonNodeNotFoundException, IOException {

		SaveMeterValue saveMeterValue = new SaveMeterValue();

		// Read json data
		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonData);

		String nodeName = "AREA_CODE";
		saveMeterValue.setAreaCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_CODE";
		saveMeterValue.setCuCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "GJ_DATE";
		saveMeterValue.setGjDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		if (isDelete == false) {
			nodeName = "GJ_GUM_YM";
			saveMeterValue.setGjGumYM(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CU_NAME";
			saveMeterValue.setCuName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "CU_USERNAME";
			saveMeterValue.setCuUserName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GJ_JUNGUM";
			saveMeterValue.setGjJunGum(GasMaxUtility.parseJsonNodeToInteger(jsonRootNode, nodeName));

			nodeName = "GJ_GUM";
			saveMeterValue.setGjGum(GasMaxUtility.parseJsonNodeToInteger(jsonRootNode, nodeName));

			nodeName = "GJ_GAGE";
			saveMeterValue.setGjGage(GasMaxUtility.parseJsonNodeToInteger(jsonRootNode, nodeName));

			nodeName = "GJ_T1_Per";
			saveMeterValue.setGjT1Per(GasMaxUtility.parseJsonNodeToInteger(jsonRootNode, nodeName));

			nodeName = "GJ_T1_kg";
			saveMeterValue.setGjT1Kg(GasMaxUtility.parseJsonNodeToInteger(jsonRootNode, nodeName));

			nodeName = "GJ_T2_Per";
			saveMeterValue.setGjT2Per(GasMaxUtility.parseJsonNodeToInteger(jsonRootNode, nodeName));

			nodeName = "GJ_T2_kg";
			saveMeterValue.setGjT2Kg(GasMaxUtility.parseJsonNodeToInteger(jsonRootNode, nodeName));

			nodeName = "GJ_JANKG";
			saveMeterValue.setGjJanKg(GasMaxUtility.parseJsonNodeToInteger(jsonRootNode, nodeName));

			nodeName = "GJ_BIGO";
			saveMeterValue.setGjBigo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "SAFE_SW_CODE";
			saveMeterValue.setSafeSwCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "SAFE_SW_NAME";
			saveMeterValue.setSafeSwName(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_X";
			saveMeterValue.setGpsX(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_Y";
			saveMeterValue.setGpsY(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "APP_User";
			saveMeterValue.setAppUser(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));
		}

		return saveMeterValue;
	}

	private CustomerMeterInfo parseJsonCustomerMeterInfo(String jsonData)
			throws JsonNodeNotFoundException, IOException {

		CustomerMeterInfo customerMeterInfo = new CustomerMeterInfo();

		// Read json data
		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonData);

		String nodeName = "AREA_CODE";
		customerMeterInfo.setAreaCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_CODE";
		customerMeterInfo.setCuCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_Gum_Turm";
		customerMeterInfo.setCuGumTerm(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_GumDate";
		customerMeterInfo.setCuGumDate(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_Barcode";
		customerMeterInfo.setCuBarCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_Meter_No";
		customerMeterInfo.setCuMeterNo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_Meter_Co";
		customerMeterInfo.setCuMeterCo(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_Meter_LR";
		customerMeterInfo.setCuMeterLR(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_Meter_TYPE";
		customerMeterInfo.setCuMeterType(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_Meter_M3";
		customerMeterInfo.setCuMeterM3(GasMaxUtility.parseJsonNodeToDouble(jsonRootNode, nodeName).floatValue());

		nodeName = "CU_Meter_DT";
		customerMeterInfo.setCuMeterDT(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "APP_User";
		customerMeterInfo.setAppUser(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		return customerMeterInfo;
	}

	private MeterCheckStatusInfo parseJsonMeterCheckStatusInfo(boolean isLocationInfoExist, String jsonData)
			throws JsonNodeNotFoundException, IOException {

		MeterCheckStatusInfo meterCheckStatusInfo = new MeterCheckStatusInfo();

		// Read json data
		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonData);

		String nodeName = "AREA_CODE";
		meterCheckStatusInfo.setAreaCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "FIND_STR";
		meterCheckStatusInfo.setFindStr(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "GUM_DATE_F";
		meterCheckStatusInfo.setGumDateF(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "GUM_DATE_T";
		meterCheckStatusInfo.setGumDateT(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "CU_CODE";
		meterCheckStatusInfo.setCuCode(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "APT_CD";
		meterCheckStatusInfo.setAptCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "SW_CD";
		meterCheckStatusInfo.setSwCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "MAN_CD";
		meterCheckStatusInfo.setManCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "JY_CD";
		meterCheckStatusInfo.setJyCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "ADDR_TEXT";
		meterCheckStatusInfo.setAddrText(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "SMART_METER_YN";
		meterCheckStatusInfo.setSmartMeterYN(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		if (isLocationInfoExist == true) {
			nodeName = "GPS_X";
			meterCheckStatusInfo.setGpsX(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

			nodeName = "GPS_Y";
			meterCheckStatusInfo.setGpsY(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));
		}

		nodeName = "SAFE_CD";
		meterCheckStatusInfo.setSafeCd(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "APP_User";
		meterCheckStatusInfo.setAppUser(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		nodeName = "OrderBy";
		meterCheckStatusInfo.setOrderBy(GasMaxUtility.parseJsonNodeToString(jsonRootNode, nodeName));

		return meterCheckStatusInfo;
	}
}
