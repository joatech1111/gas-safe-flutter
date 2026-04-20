package com.joatech.gasmax.webapi.controllers;

import java.util.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.joatech.gasmax.webapi.defines.GasMaxErrors;
import com.joatech.gasmax.webapi.domains.AppUserSafe;
import com.joatech.gasmax.webapi.domains.RestAPIResult;
import com.joatech.gasmax.webapi.services.AppUserSafeService;

@RestController
@RequestMapping("/gas/api/admin")
public class AdminController {

    private final Logger logger = LoggerFactory.getLogger(getClass());

    @Autowired
    private AppUserSafeService appUserSafeService;

    @GetMapping("users")
    public RestAPIResult getAllUsers() {
        logger.debug("Admin: Get all users");
        try {
            List<AppUserSafe> users = appUserSafeService.getAllAppUserSafe();

            List<Map<String, Object>> result = new ArrayList<>();
            for (AppUserSafe u : users) {
                Map<String, Object> map = new LinkedHashMap<>();
                map.put("HP_IMEI", u.getHpImei());
                map.put("HP_State", u.getHpState());
                map.put("HP_Model", u.getHpModel());
                map.put("HP_SNO", u.getHpSNo());
                map.put("APP_VER", u.getAppVersion());
                map.put("SVR_IP", u.getServerIp());
                map.put("SVR_DBName", u.getServerDBName());
                map.put("SVR_User", u.getServerUser());
                map.put("SVR_Pass", u.getServerPassword());
                map.put("SVR_Port", u.getServerPort());
                map.put("Login_Co", u.getLoginCo());
                map.put("Login_Name", u.getLoginName());
                map.put("Login_User", u.getLoginUser());
                map.put("Login_Pass", u.getLoginPassword());
                map.put("BA_Area_CODE", u.getBaAreaCode());
                map.put("BA_SW_CODE", u.getBaSWCode());
                map.put("BA_Gubun_CODE", u.getBaGubunCode());
                map.put("BA_JY_Code", u.getBaJYCode());
                map.put("BA_OrderBy", u.getBaOrderBy());
                map.put("Safe_SW_CODE", u.getSafeSWCode());
                map.put("License_Date", u.getLicenseDate());
                map.put("Login_StartDate", u.getLoginStartDate());
                map.put("Login_LastDate", u.getLoginLastDate());
                map.put("Login_EndDate", u.getLoginEndDate());
                map.put("Login_info", u.getLoginInfo());
                map.put("Login_Memo", u.getLoginMemo());
                map.put("APP_Cert", u.getAppCert());
                map.put("GPS_SEARCH_YN", u.getGpsSearchYN());
                result.add(map);
            }

            return new RestAPIResult(GasMaxErrors.ERROR_OK, GasMaxErrors.ERROR_CODE_OK, result);
        } catch (Exception e) {
            logger.error("Admin getAllUsers error", e);
            return new RestAPIResult("QUERY_FAILED", -1, e.getMessage());
        }
    }

    @PutMapping("users/{hpImei}")
    public RestAPIResult updateUser(@PathVariable String hpImei, @RequestBody Map<String, String> data) {
        logger.debug("Admin: Update user {}", hpImei);
        try {
            int rows = appUserSafeService.adminUpdateUser(hpImei, data);
            return new RestAPIResult(GasMaxErrors.ERROR_OK, GasMaxErrors.ERROR_CODE_OK, rows);
        } catch (Exception e) {
            logger.error("Admin update error", e);
            return new RestAPIResult("UPDATE_FAILED", -1, e.getMessage());
        }
    }

    @PostMapping("users")
    public RestAPIResult insertUser(@RequestBody Map<String, String> data) {
        logger.debug("Admin: Insert user");
        try {
            int rows = appUserSafeService.adminInsertUser(data);
            return new RestAPIResult(GasMaxErrors.ERROR_OK, GasMaxErrors.ERROR_CODE_OK, rows);
        } catch (Exception e) {
            logger.error("Admin insert error", e);
            return new RestAPIResult("INSERT_FAILED", -1, e.getMessage());
        }
    }

    @DeleteMapping("users/{hpImei}")
    public RestAPIResult deleteUser(@PathVariable String hpImei) {
        logger.debug("Admin: Delete user {}", hpImei);
        try {
            int rows = appUserSafeService.adminDeleteUser(hpImei);
            return new RestAPIResult(GasMaxErrors.ERROR_OK, GasMaxErrors.ERROR_CODE_OK, rows);
        } catch (Exception e) {
            logger.error("Admin delete error", e);
            return new RestAPIResult("DELETE_FAILED", -1, e.getMessage());
        }
    }
}
