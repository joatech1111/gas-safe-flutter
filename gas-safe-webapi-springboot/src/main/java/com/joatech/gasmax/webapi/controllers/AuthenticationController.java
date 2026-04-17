package com.joatech.gasmax.webapi.controllers;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.joatech.gasmax.webapi.defines.GasMaxErrors;
import com.joatech.gasmax.webapi.domains.AppUserSafe;
import com.joatech.gasmax.webapi.domains.RestAPIResult;
import com.joatech.gasmax.webapi.exceptions.InvalidSessionIdException;
import com.joatech.gasmax.webapi.exceptions.SessionIdNotReceivedException;
import com.joatech.gasmax.webapi.services.AppUserSafeService;
import com.joatech.gasmax.webapi.services.UserSessionService;

@RestController
@RequestMapping("/gas/api/auth")
public class AuthenticationController {

    /*================================================================
     * Private Members
     ================================================================*/
    private final Logger logger = LoggerFactory.getLogger(getClass());

    /*================================================================
     * Private Autowired Members
     ================================================================*/
    @Autowired
    private AppUserSafeService appUserSafeService;
    @Autowired
    private UserSessionService userSessionService;

    /*================================================================
     * Public Rest API
     ================================================================*/
    @RequestMapping("/status")
    public String status() {

        Random random = new Random();
        int length = 15;  // 생성할 문자열의 길이
        StringBuilder randomString = new StringBuilder();

        for (int i = 0; i < length; i++) {
            // 대소문자 알파벳을 포함한 난수 생성
            char randomChar = (char) (random.nextInt(26) + 'a' + (random.nextBoolean() ? 0 : 'A' - 'a'));
            randomString.append(randomChar);
        }
        //String CONT_FILE_URL = "http://118.222.92.10:9494/download/" + randomString.toString() + ".pdf";
        String CONT_FILE_URL = "http://121.254.173.234:9999/download/" + randomString.toString() + ".pdf";

        return "Random string [ " + CONT_FILE_URL + "]";

    }

	/*================================================================
	 * Public Rest API
	 ================================================================*/
//	@PostMapping("login")
//	public RestAPIResult login(@RequestBody String jsonLoginData)
//			throws JsonParseException, IOException {
//
//		logger.debug("Start login API : Received data - {}", jsonLoginData);
//
//		String result = GasMaxErrors.ERROR_OK;
//		int resultCode = GasMaxErrors.ERROR_CODE_OK;
//		Object resultData = "";
//		RestAPIResult apiResult = null;
//
//		// Read login json data
//		ObjectMapper mapper = new ObjectMapper();
//		JsonNode jsonRootNode = mapper.readTree(jsonLoginData);
//
//		String loginId = "";
//		String loginPwd = "";
//		String uuid = "";
//		String mobileNumber = "";
//		String appVersion = "";
//
//		JsonNode jsonNode = jsonRootNode.get("loginId");
//		if (jsonNode == null) {
//			result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " loginId";
//			resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
//			apiResult = new RestAPIResult(result, resultCode, resultData);
//			return apiResult;
//		}
//		loginId = jsonNode.asText();
//
//		jsonNode = jsonRootNode.get("loginPwd");
//		if (jsonNode == null) {
//			result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " loginPwd";
//			resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
//			apiResult = new RestAPIResult(result, resultCode, resultData);
//			return apiResult;
//		}
//		loginPwd = jsonNode.asText();
//
//		jsonNode = jsonRootNode.get("uuid");
//		if (jsonNode == null) {
//			result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " uuid";
//			resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
//			apiResult = new RestAPIResult(result, resultCode, resultData);
//			return apiResult;
//		}
//		uuid = jsonNode.asText();
//
//		jsonNode = jsonRootNode.get("mobileNumber");
//		if (jsonNode == null) {
//			result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " mobileNumber";
//			resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
//			apiResult = new RestAPIResult(result, resultCode, resultData);
//			return apiResult;
//		}
//		mobileNumber = jsonNode.asText();
//
//		jsonNode = jsonRootNode.get("appVersion");
//		if (jsonNode != null) {
//			appVersion = jsonNode.asText();
//		}
//
//		// Make new database connection to app db auth
//		AppUserSafe appUserSafe = null;
//		Optional<AppUserSafe> optAppUserSafe = null;
//		try {
//			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei(uuid);
//
//			System.out.println(optAppUserSafe);
//			System.out.println(optAppUserSafe);
//			System.out.println(optAppUserSafe);
//			System.out.println(optAppUserSafe);
//			System.out.println(optAppUserSafe);
//			System.out.println(optAppUserSafe);
//
//
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//
//		if (optAppUserSafe.isPresent()) {
//			appUserSafe = optAppUserSafe.get();
//
//			if (appVersion.length() == 0) {
//				appVersion = appUserSafe.getAppVersion();
//			}
//
//			if (appUserSafe.getLoginUser().equals(loginId) == false) {
//				result = GasMaxErrors.ERROR_LOGIN_ID_NOT_MATCHED;
//				resultCode = GasMaxErrors.ERROR_CODE_LOGIN_ID_NOT_MATCHED;
//				apiResult = new RestAPIResult(result, resultCode, resultData);
//				return apiResult;
//			}
//
//			if (appUserSafe.getLoginPassword().equals(loginPwd) == false) {
//				result = GasMaxErrors.ERROR_LOGIN_PWD_NOT_MATCHED;
//				resultCode = GasMaxErrors.ERROR_CODE_LOGIN_PWD_NOT_MATCHED;
//				apiResult = new RestAPIResult(result, resultCode, resultData);
//				return apiResult;
//			}
//
//			if (appUserSafe.getHpSNo().equals(mobileNumber) == false) {
//				result = GasMaxErrors.ERROR_MOBILE_NUMBER_NOT_MATCHED;
//				resultCode = GasMaxErrors.ERROR_CODE_MOBILE_NUMBER_NOT_MATCHED;
//				apiResult = new RestAPIResult(result, resultCode, resultData);
//				return apiResult;
//			}
//
//			String sessionId = userSessionService.makeNewSession(appUserSafe);
//			Map<String, Object> mapResult = new HashMap<String, Object>();
//			mapResult.put("HP_SNO", appUserSafe.getHpSNo());
//			mapResult.put("Login_Co", appUserSafe.getLoginCo());
//			mapResult.put("Login_Name", appUserSafe.getLoginName());
//			mapResult.put("Login_User", appUserSafe.getLoginUser());
//			mapResult.put("Login_Pass", appUserSafe.getLoginPassword());
//			mapResult.put("BA_Area_CODE", appUserSafe.getBaAreaCode());
//			mapResult.put("BA_SW_CODE", appUserSafe.getBaSWCode());
//			mapResult.put("BA_Gubun_CODE", appUserSafe.getBaGubunCode());
//			mapResult.put("BA_JY_Code", appUserSafe.getBaJYCode());
//			mapResult.put("BA_OrderBy", appUserSafe.getBaOrderBy());
//			mapResult.put("Safe_SW_CODE", appUserSafe.getSafeSWCode());
//			mapResult.put("Login_StartDate", appUserSafe.getLoginStartDate());
//			mapResult.put("Login_LastDate", appUserSafe.getLoginLastDate());
//			mapResult.put("Login_EndDate", appUserSafe.getLoginEndDate());
//			mapResult.put("Login_info", appUserSafe.getLoginInfo());
//			mapResult.put("Login_Memo", appUserSafe.getLoginMemo());
//			mapResult.put("APP_Cert", appUserSafe.getAppCert());
//			mapResult.put("GPS_SEARCH_YN", appUserSafe.getGpsSearchYN());
//
///*
// * 			mapResult.put("companyCode", appUserSafe.getBaAreaCode());
//			mapResult.put("companyName", appUserSafe.getLoginCo());
//			mapResult.put("employeeCode", appUserSafe.getBaSWCode());
//			mapResult.put("manageTypeCode", appUserSafe.getBaGubunCode());
//			mapResult.put("metermanCode", appUserSafe.getSafeSWCode());
//			mapResult.put("metermanName", appUserSafe.getLoginName());
//			mapResult.put("userPermission", appUserSafe.getAppCert());
//			mapResult.put("areaTypeCode", appUserSafe.getBaJYCode());
//			mapResult.put("listSortCode", appUserSafe.getBaOrderBy());
//			mapResult.put("lastLoginDate", appUserSafe.getLoginLastDate());
//*/
//			mapResult.put("sToken", sessionId);
//
//			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//			appUserSafeService.updateAppUserSafe(appVersion, dateFormat.format(new Date()), uuid);
//			resultData = mapResult;
//
//		}
//		else {
//			// User Information not found
//			result = GasMaxErrors.ERROR_LOGIN_INFO_NOT_FOUND;
//			resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFO_NOT_FOUND;
//		}
//
//		apiResult = new RestAPIResult(result, resultCode, resultData);
//		return apiResult;
//	}

    /**
     * todo: 로그인 V2 test/test 로그인으로 패스가능하게끔!
     *
     * @param jsonLoginData
     * @return
     * @throws JsonParseException
     * @throws IOException
     */
	@PostMapping("login")
	public RestAPIResult login(@RequestBody String jsonLoginData) throws JsonParseException, IOException {

		logger.debug("Start login API : Received data - {}", jsonLoginData);

		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonLoginData);

		String loginId = "";
		String loginPwd = "";
		String uuid = "";
		String mobileNumber = "";
		String appVersion = "";

		JsonNode jsonNode = jsonRootNode.get("loginId");
		if (jsonNode == null) {
			return new RestAPIResult(GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " loginId",
					GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED, resultData);
		}
		loginId = jsonNode.asText();

		jsonNode = jsonRootNode.get("loginPwd");
		if (jsonNode == null) {
			return new RestAPIResult(GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " loginPwd",
					GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED, resultData);
		}
		loginPwd = jsonNode.asText();

		jsonNode = jsonRootNode.get("uuid");
		if (jsonNode == null) {
			return new RestAPIResult(GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " uuid",
					GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED, resultData);
		}
		uuid = jsonNode.asText();

		jsonNode = jsonRootNode.get("mobileNumber");
		if (jsonNode == null) {
			return new RestAPIResult(GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " mobileNumber",
					GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED, resultData);
		}
		mobileNumber = jsonNode.asText();

		jsonNode = jsonRootNode.get("appVersion");
		if (jsonNode != null) {
			appVersion = jsonNode.asText();
		}

		// ✅ test/test, test2/test2 케이스일 때 강제 uuid 덮어쓰기
		boolean isTestLogin = false;
		if ("test".equals(loginId) && "test".equals(loginPwd)) {
			uuid = "355325070280849";
			isTestLogin = true;
		} else if ("test2".equals(loginId) && "test2".equals(loginPwd)) {
			uuid = "355325070280850";
			isTestLogin = true;
		}

		// ✅ uuid로 사용자 조회
		AppUserSafe appUserSafe = null;
		Optional<AppUserSafe> optAppUserSafe = Optional.empty();
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei(uuid);
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (optAppUserSafe.isPresent()) {
			appUserSafe = optAppUserSafe.get();

			if (appVersion.isEmpty()) {
				appVersion = appUserSafe.getAppVersion();
			}

			// ✅ 일반 로그인일 때만 id, pwd, mobileNumber 매칭검사
			if (!isTestLogin) {
				if (!appUserSafe.getLoginUser().equals(loginId)) {
					return new RestAPIResult(GasMaxErrors.ERROR_LOGIN_ID_NOT_MATCHED,
							GasMaxErrors.ERROR_CODE_LOGIN_ID_NOT_MATCHED, resultData);
				}

				if (!appUserSafe.getLoginPassword().equals(loginPwd)) {
					return new RestAPIResult(GasMaxErrors.ERROR_LOGIN_PWD_NOT_MATCHED,
							GasMaxErrors.ERROR_CODE_LOGIN_PWD_NOT_MATCHED, resultData);
				}

				if (!appUserSafe.getHpSNo().equals(mobileNumber)) {
					return new RestAPIResult(GasMaxErrors.ERROR_MOBILE_NUMBER_NOT_MATCHED,
							GasMaxErrors.ERROR_CODE_MOBILE_NUMBER_NOT_MATCHED, resultData);
				}
			}

			// ✅ 로그인 성공 처리
			String sessionId = userSessionService.makeNewSession(appUserSafe);

			Map<String, Object> mapResult = new HashMap<>();
			mapResult.put("HP_SNO", appUserSafe.getHpSNo());
			mapResult.put("Login_Co", appUserSafe.getLoginCo());
			mapResult.put("Login_Name", appUserSafe.getLoginName());
			mapResult.put("Login_User", appUserSafe.getLoginUser());
			mapResult.put("Login_Pass", appUserSafe.getLoginPassword());
			mapResult.put("BA_Area_CODE", appUserSafe.getBaAreaCode());
			mapResult.put("BA_SW_CODE", appUserSafe.getBaSWCode());
			mapResult.put("BA_Gubun_CODE", appUserSafe.getBaGubunCode());
			mapResult.put("BA_JY_Code", appUserSafe.getBaJYCode());
			mapResult.put("BA_OrderBy", appUserSafe.getBaOrderBy());
			mapResult.put("Safe_SW_CODE", appUserSafe.getSafeSWCode());
			mapResult.put("Login_StartDate", appUserSafe.getLoginStartDate());
			mapResult.put("Login_LastDate", appUserSafe.getLoginLastDate());
			mapResult.put("Login_EndDate", appUserSafe.getLoginEndDate());
			mapResult.put("Login_info", appUserSafe.getLoginInfo());
			mapResult.put("Login_Memo", appUserSafe.getLoginMemo());
			mapResult.put("APP_Cert", appUserSafe.getAppCert());
			mapResult.put("GPS_SEARCH_YN", appUserSafe.getGpsSearchYN());
			mapResult.put("sToken", sessionId);

			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			appUserSafeService.updateAppUserSafe(appVersion, dateFormat.format(new Date()), uuid);

			return new RestAPIResult(result, resultCode, mapResult);
		} else {
			return new RestAPIResult(GasMaxErrors.ERROR_LOGIN_INFO_NOT_FOUND,
					GasMaxErrors.ERROR_CODE_LOGIN_INFO_NOT_FOUND, resultData);
		}
	}



	/**
	 * 전화번호로 업체(사용자) 목록 조회 (비밀번호 없이)
	 * Flutter 전화번호 로그인 1단계: 전화번호 입력 → 업체 목록 표시
	 */
	@PostMapping("searchByPhone")
	public RestAPIResult searchByPhone(@RequestBody String jsonData) throws JsonParseException, IOException {

		logger.debug("Start searchByPhone API : Received data - {}", jsonData);

		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonData);

		JsonNode jsonNode = jsonRootNode.get("phoneNumber");
		if (jsonNode == null) {
			return new RestAPIResult(GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " phoneNumber",
					GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED, "");
		}
		String phoneNumber = jsonNode.asText();

		// 전화번호로 사용자 목록 조회
		List<AppUserSafe> userList = new ArrayList<>();
		try {
			userList = appUserSafeService.getAppUserSafeListByHpSNo(phoneNumber);
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (userList.isEmpty()) {
			return new RestAPIResult("등록되지 않은 전화번호입니다.",
					GasMaxErrors.ERROR_CODE_LOGIN_INFO_NOT_FOUND, "");
		}

		// 사용자 목록 반환 (단일이든 복수든 List로)
		List<Map<String, String>> userInfoList = new ArrayList<>();
		for (AppUserSafe u : userList) {
			Map<String, String> info = new HashMap<>();
			info.put("HP_IMEI", u.getHpImei());
			info.put("Login_Name", u.getLoginName());
			info.put("Login_User", u.getLoginUser());
			info.put("Login_Co", u.getLoginCo());
			info.put("HP_Model", u.getHpModel());
			userInfoList.add(info);
		}

		return new RestAPIResult(GasMaxErrors.ERROR_OK, GasMaxErrors.ERROR_CODE_OK, userInfoList);
	}

	/**
	 * 전화번호 + 비밀번호 기반 로그인
	 * 전화번호(HP_SNO)로 사용자를 조회 후 비밀번호 검증하여 로그인 처리
	 * 복수 사용자인 경우: selectedImei 없으면 사용자 목록 반환 (resultCode=200)
	 * 복수 사용자인 경우: selectedImei 있으면 해당 사용자로 로그인
	 */
	@PostMapping("loginByPhone")
	public RestAPIResult loginByPhone(@RequestBody String jsonLoginData) throws JsonParseException, IOException {

		logger.debug("Start loginByPhone API : Received data - {}", jsonLoginData);

		String result = GasMaxErrors.ERROR_OK;
		int resultCode = GasMaxErrors.ERROR_CODE_OK;
		Object resultData = "";

		ObjectMapper mapper = new ObjectMapper();
		JsonNode jsonRootNode = mapper.readTree(jsonLoginData);

		String phoneNumber = "";
		String loginPwd = "";
		String appVersion = "";
		String selectedImei = "";

		JsonNode jsonNode = jsonRootNode.get("phoneNumber");
		if (jsonNode == null) {
			return new RestAPIResult(GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " phoneNumber",
					GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED, resultData);
		}
		phoneNumber = jsonNode.asText();

		jsonNode = jsonRootNode.get("loginPwd");
		if (jsonNode == null) {
			return new RestAPIResult(GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " loginPwd",
					GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED, resultData);
		}
		loginPwd = jsonNode.asText();

		jsonNode = jsonRootNode.get("appVersion");
		if (jsonNode != null) {
			appVersion = jsonNode.asText();
		}

		jsonNode = jsonRootNode.get("selectedImei");
		if (jsonNode != null) {
			selectedImei = jsonNode.asText();
		}

		// 전화번호로 사용자 목록 조회
		List<AppUserSafe> userList = new ArrayList<>();
		try {
			userList = appUserSafeService.getAppUserSafeListByHpSNo(phoneNumber);
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (userList.isEmpty()) {
			return new RestAPIResult("등록되지 않은 전화번호입니다.",
					GasMaxErrors.ERROR_CODE_LOGIN_INFO_NOT_FOUND, resultData);
		}

		// 복수 사용자 && selectedImei 미지정 → 사용자 목록 반환
		if (userList.size() > 1 && selectedImei.isEmpty()) {
			List<Map<String, String>> userInfoList = new ArrayList<>();
			for (AppUserSafe u : userList) {
				Map<String, String> info = new HashMap<>();
				info.put("HP_IMEI", u.getHpImei());
				info.put("Login_Name", u.getLoginName());
				info.put("Login_User", u.getLoginUser());
				info.put("Login_Co", u.getLoginCo());
				info.put("HP_Model", u.getHpModel());
				userInfoList.add(info);
			}
			return new RestAPIResult("MULTI_USER", 200, userInfoList);
		}

		// 대상 사용자 결정
		AppUserSafe appUserSafe = null;
		if (!selectedImei.isEmpty()) {
			for (AppUserSafe u : userList) {
				if (u.getHpImei().equals(selectedImei)) {
					appUserSafe = u;
					break;
				}
			}
			if (appUserSafe == null) {
				return new RestAPIResult("선택한 사용자를 찾을 수 없습니다.",
						GasMaxErrors.ERROR_CODE_LOGIN_INFO_NOT_FOUND, resultData);
			}
		} else {
			appUserSafe = userList.get(0);
		}

		// 비밀번호 검증
		if (!appUserSafe.getLoginPassword().equals(loginPwd)) {
			return new RestAPIResult(GasMaxErrors.ERROR_LOGIN_PWD_NOT_MATCHED,
					GasMaxErrors.ERROR_CODE_LOGIN_PWD_NOT_MATCHED, resultData);
		}

		if (appVersion.isEmpty()) {
			appVersion = appUserSafe.getAppVersion();
		}

		// 로그인 성공 처리
		String sessionId = userSessionService.makeNewSession(appUserSafe);

		Map<String, Object> mapResult = new HashMap<>();
		mapResult.put("HP_SNO", appUserSafe.getHpSNo());
		mapResult.put("Login_Co", appUserSafe.getLoginCo());
		mapResult.put("Login_Name", appUserSafe.getLoginName());
		mapResult.put("Login_User", appUserSafe.getLoginUser());
		mapResult.put("Login_Pass", appUserSafe.getLoginPassword());
		mapResult.put("BA_Area_CODE", appUserSafe.getBaAreaCode());
		mapResult.put("BA_SW_CODE", appUserSafe.getBaSWCode());
		mapResult.put("BA_Gubun_CODE", appUserSafe.getBaGubunCode());
		mapResult.put("BA_JY_Code", appUserSafe.getBaJYCode());
		mapResult.put("BA_OrderBy", appUserSafe.getBaOrderBy());
		mapResult.put("Safe_SW_CODE", appUserSafe.getSafeSWCode());
		mapResult.put("Login_StartDate", appUserSafe.getLoginStartDate());
		mapResult.put("Login_LastDate", appUserSafe.getLoginLastDate());
		mapResult.put("Login_EndDate", appUserSafe.getLoginEndDate());
		mapResult.put("Login_info", appUserSafe.getLoginInfo());
		mapResult.put("Login_Memo", appUserSafe.getLoginMemo());
		mapResult.put("APP_Cert", appUserSafe.getAppCert());
		mapResult.put("GPS_SEARCH_YN", appUserSafe.getGpsSearchYN());
		mapResult.put("sToken", sessionId);

		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		appUserSafeService.updateAppUserSafe(appVersion, dateFormat.format(new Date()), appUserSafe.getHpImei());

		return new RestAPIResult(result, resultCode, mapResult);
	}

	@PostMapping("signup")
    public RestAPIResult signUp(@RequestBody String jsonSignUpData)
            throws JsonParseException, IOException {

        logger.debug("Start sign up API : Received data - {}", jsonSignUpData);

        String result = GasMaxErrors.ERROR_OK;
        int resultCode = GasMaxErrors.ERROR_CODE_OK;
        Object resultData = "";
        RestAPIResult apiResult = null;

        // Read login json data
        ObjectMapper mapper = new ObjectMapper();
        JsonNode jsonRootNode = mapper.readTree(jsonSignUpData);

        String hpImei = "";
        String hpModel = "";
        String hpSNo = "";
        String appVer = "";
        String loginCo = "";
        String loginName = "";
        String loginUser = "";
        String loginPass = "";

        JsonNode jsonNode = jsonRootNode.get("HP_IMEI");
        if (jsonNode == null) {
            result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " HP_IMEI";
            resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
            apiResult = new RestAPIResult(result, resultCode, resultData);
            return apiResult;
        }
        hpImei = jsonNode.asText();

        jsonNode = jsonRootNode.get("HP_Model");
        if (jsonNode == null) {
            result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " HP_Model";
            resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
            apiResult = new RestAPIResult(result, resultCode, resultData);
            return apiResult;
        }
        hpModel = jsonNode.asText();

        jsonNode = jsonRootNode.get("HP_SNO");
        if (jsonNode == null) {
            result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " HP_SNO";
            resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
            apiResult = new RestAPIResult(result, resultCode, resultData);
            return apiResult;
        }
        hpSNo = jsonNode.asText();

        jsonNode = jsonRootNode.get("APP_VER");
        if (jsonNode == null) {
            result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " APP_VER";
            resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
            apiResult = new RestAPIResult(result, resultCode, resultData);
            return apiResult;
        }
        appVer = jsonNode.asText();

        jsonNode = jsonRootNode.get("Login_Co");
        if (jsonNode == null) {
            result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " Login_Co";
            resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
            apiResult = new RestAPIResult(result, resultCode, resultData);
            return apiResult;
        }
        loginCo = jsonNode.asText();

        jsonNode = jsonRootNode.get("Login_Name");
        if (jsonNode == null) {
            result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " Login_Name";
            resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
            apiResult = new RestAPIResult(result, resultCode, resultData);
            return apiResult;
        }
        loginName = jsonNode.asText();

        jsonNode = jsonRootNode.get("Login_User");
        if (jsonNode == null) {
            result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " Login_User";
            resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
            apiResult = new RestAPIResult(result, resultCode, resultData);
            return apiResult;
        }
        loginUser = jsonNode.asText();

        jsonNode = jsonRootNode.get("Login_Pass");
        if (jsonNode == null) {
            result = GasMaxErrors.ERROR_LOGIN_INFORMAION_NOT_SUMBITED + " Login_Pass";
            resultCode = GasMaxErrors.ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED;
            apiResult = new RestAPIResult(result, resultCode, resultData);
            return apiResult;
        }
        loginPass = jsonNode.asText();

        // Make new database connection to app db auth
        AppUserSafe appUserSafe = new AppUserSafe();
        appUserSafe.setHpImei(hpImei);
        appUserSafe.setHpSNo(hpSNo);
        appUserSafe.setHpModel(hpModel);
        appUserSafe.setAppVersion(appVer);
        appUserSafe.setLoginCo(loginCo);
        appUserSafe.setLoginName(loginName);
        appUserSafe.setLoginUser(loginUser);
        appUserSafe.setLoginPassword(loginPass);

        resultData = appUserSafeService.addNewAppUserSafe(appUserSafe);

        apiResult = new RestAPIResult(result, resultCode, resultData);
        return apiResult;
    }

    @GetMapping("logout")
    public RestAPIResult logout(
            @RequestParam("sessionid") Optional<String> optSessionId)
            throws SessionIdNotReceivedException, InvalidSessionIdException {
        String result = GasMaxErrors.ERROR_OK;
        int resultCode = GasMaxErrors.ERROR_CODE_OK;
        Object resultData = "";

        if (optSessionId.isPresent() == false) {
            throw new SessionIdNotReceivedException(GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED);
        } else {
            String sessionId = optSessionId.get();

            AppUserSafe appUserSafe = userSessionService.getSessionInfo(sessionId);
            if (appUserSafe == null) {
                throw new InvalidSessionIdException(GasMaxErrors.ERROR_SESSION_ID_IS_INVALID);
            }

            userSessionService.expireSession(sessionId);
        }

        RestAPIResult apiResult = new RestAPIResult(result, resultCode, resultData);
        return apiResult;
    }


}
