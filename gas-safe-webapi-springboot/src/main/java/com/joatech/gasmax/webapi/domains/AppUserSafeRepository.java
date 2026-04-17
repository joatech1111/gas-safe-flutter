package com.joatech.gasmax.webapi.domains;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;

public class AppUserSafeRepository extends GasMaxRepository {
	
	public AppUserSafeRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}

	public Optional<AppUserSafe> findByHpImei(String hpImei) {
		String queryString   =  " SELECT HP_IMEI, HP_State, HP_Model, HP_SNO, APP_VER, SVR_IP_NO AS SVR_IP, SVR_DBName, SVR_User, SVR_Pass, SVR_Port, "
		 					 +  " Login_Co, Login_Name, Login_User, Login_Pass, BA_Area_CODE, BA_SW_CODE, BA_Gubun_CODE,"
							 +  " BA_JY_Code, BA_OrderBy,Safe_SW_CODE , License_Date, Login_StartDate, Login_LastDate, Login_EndDate,"
							 +  " Login_info, Login_Memo, APP_Cert, GPS_SEARCH_YN from APPUser_Safe "
							 +  " WHERE HP_State = 'Y' AND HP_IMEI = ?";
		
		//HP_IMEI, HP_State, HP_Model, HP_SNO, APP_VER, SVR_IP_NO AS SVR_IP, SVR_DBName, SVR_User, SVR_Pass, SVR_Port,
		//Login_Co, Login_Name, Login_User, Login_Pass, BA_Area_CODE, BA_SW_CODE, BA_Gubun_CODE,
		//BA_JY_Code, BA_OrderBy,Safe_SW_CODE , License_Date, Login_StartDate, Login_LastDate, Login_EndDate,
		//Login_info, Login_Memo, APP_Cert, GPS_SEARCH_YN
		
		
		
		//String queryString = "SELECT * FROM APPUser_Safe WHERE HP_State = 'Y' AND HP_IMEI = ?";

        return jdbcTemplate.queryForObject(
        		queryString,
                (rs, rowNum) -> {
                	AppUserSafe appUserSafe = new AppUserSafe();
                	appUserSafe.setHpImei(rs.getString("HP_IMEI"));
                	appUserSafe.setHpState(rs.getString("HP_State"));
                	appUserSafe.setHpModel(rs.getString("HP_Model"));
                	appUserSafe.setHpSNo(rs.getString("HP_SNO"));
                	appUserSafe.setAppVersion(rs.getString("APP_VER"));
                	appUserSafe.setServerIp(rs.getString("SVR_IP"));
                	appUserSafe.setServerDBName(rs.getString("SVR_DBName"));
                	appUserSafe.setServerUser(rs.getString("SVR_User"));
                	appUserSafe.setServerPassword( rs.getString("SVR_Pass"));
                	appUserSafe.setServerPort(rs.getString("SVR_Port"));
                	appUserSafe.setLoginCo(rs.getString("Login_Co"));
                	appUserSafe.setLoginName(rs.getString("Login_Name"));
                	appUserSafe.setLoginUser(rs.getString("Login_User"));
                	appUserSafe.setLoginPassword(rs.getString("Login_Pass"));
                	appUserSafe.setBaAreaCode(rs.getString("BA_Area_CODE"));
                	appUserSafe.setBaSWCode( rs.getString("BA_SW_CODE"));
                	appUserSafe.setBaGubunCode(rs.getString("BA_Gubun_CODE"));
                	appUserSafe.setBaJYCode(rs.getString("BA_JY_Code"));
                	appUserSafe.setBaOrderBy(rs.getString("BA_OrderBy"));
                	appUserSafe.setSafeSWCode(rs.getString("Safe_SW_CODE"));
                	appUserSafe.setLicenseDate(rs.getString("License_Date"));
                	appUserSafe.setLoginStartDate(rs.getString("Login_StartDate"));
                	appUserSafe.setLoginLastDate(rs.getString("Login_LastDate"));
                	appUserSafe.setLoginEndDate(rs.getString("Login_EndDate"));
                	appUserSafe.setLoginInfo(rs.getString("Login_info"));
                	appUserSafe.setLoginMemo(rs.getString("Login_Memo"));
                	appUserSafe.setAppCert(rs.getString("APP_Cert"));
                	appUserSafe.setGpsSearchYN(rs.getString("GPS_SEARCH_YN"));
                	
                	return Optional.of(appUserSafe);
                },
                hpImei
        );
	}

	public List<AppUserSafe> findAll() {
		
		//String queryString = "SELECT * FROM APPUser_Safe WHERE HP_State = 'Y'";
		String queryString   =  " SELECT HP_IMEI, HP_State, HP_Model, HP_SNO, APP_VER,  SVR_IP_NO AS SVR_IP, SVR_DBName, SVR_User, SVR_Pass, SVR_Port, "
		 					 +  " Login_Co, Login_Name, Login_User, Login_Pass, BA_Area_CODE, BA_SW_CODE, BA_Gubun_CODE,"
							 +  " BA_JY_Code, BA_OrderBy,Safe_SW_CODE , License_Date, Login_StartDate, Login_LastDate, Login_EndDate,"
							 +  " Login_info, Login_Memo, APP_Cert, GPS_SEARCH_YN from APPUser_Safe "
							 +  " WHERE HP_State = 'Y'";


		List<Map<String, Object>> rows = jdbcTemplate.queryForList(queryString);
		
		List<AppUserSafe> appUserSafeList = new ArrayList<AppUserSafe>();
		for (Map<String, Object> row : rows) {
			System.out.println(row);
			AppUserSafe appUserSafe = new AppUserSafe();
			
			Object value = row.get("HP_IMEI");
			if (value != null) 
				appUserSafe.setHpImei(value.toString());

			value = row.get("HP_State");
			if (value != null) 
				appUserSafe.setHpState(value.toString());

			value = row.get("HP_Model");
			if (value != null) 
				appUserSafe.setHpModel(value.toString());
			
			value = row.get("HP_SNO");
			if (value != null) 
				appUserSafe.setHpSNo(value.toString());
			
			value = row.get("APP_VER");
			if (value != null) 
				appUserSafe.setAppVersion(value.toString());
			
			value = row.get("SVR_IP");
			if (value != null) 
				appUserSafe.setServerIp(value.toString());
			
			value = row.get("SVR_DBName");
			if (value != null) 
				appUserSafe.setServerDBName(value.toString());
			
			value = row.get("SVR_User");
			if (value != null) 
				appUserSafe.setServerUser(value.toString());
			
			value = row.get("SVR_Pass");
			if (value != null) 
				appUserSafe.setServerPassword(value.toString());
			
			value = row.get("SVR_Port");
			if (value != null) 
				appUserSafe.setServerPort(value.toString());
			
			value = row.get("Login_Co");
			if (value != null) 
				appUserSafe.setLoginCo(value.toString());
			
			value = row.get("Login_Name");
			if (value != null) 
				appUserSafe.setLoginName(value.toString());
			
			value = row.get("Login_User");
			if (value != null) 
				appUserSafe.setLoginUser(value.toString());
			
			value = row.get("Login_Pass");
			if (value != null) 
				appUserSafe.setLoginPassword(value.toString());
			
			value = row.get("BA_Area_CODE");
			if (value != null) 
				appUserSafe.setBaAreaCode(value.toString());
			
			value = row.get("BA_SW_CODE");
			if (value != null) 
				appUserSafe.setBaSWCode(value.toString());
			
			value = row.get("BA_Gubun_CODE");
			if (value != null) 
				appUserSafe.setBaGubunCode(value.toString());
			
			value = row.get("BA_JY_Code");
			if (value != null) 
				appUserSafe.setBaJYCode(value.toString());

			value = row.get("BA_OrderBy");
			if (value != null) 
				appUserSafe.setBaOrderBy(value.toString());
			
			value = row.get("Safe_SW_CODE");
			if (value != null) 
				appUserSafe.setSafeSWCode(value.toString());
			
			value = row.get("License_Date");
			if (value != null) 
				appUserSafe.setLicenseDate(value.toString());

			value = row.get("Login_StartDate");
			if (value != null) 
				appUserSafe.setLoginStartDate(value.toString());
			
			value = row.get("Login_LastDate");
			if (value != null) 
				appUserSafe.setLoginLastDate(value.toString());
			
			value = row.get("Login_EndDate");
			if (value != null) 
				appUserSafe.setLoginEndDate(value.toString());

			value = row.get("Login_info");
			if (value != null) 
				appUserSafe.setLoginInfo(value.toString());
			
			value = row.get("Login_Memo");
			if (value != null) 
				appUserSafe.setLoginMemo(value.toString());

			value = row.get("APP_Cert");
			if (value != null) 
				appUserSafe.setAppCert(value.toString());
			
			value = row.get("GPS_SEARCH_YN");
			if (value != null) 
				appUserSafe.setGpsSearchYN(value.toString());
        	
        	appUserSafeList.add(appUserSafe);
		}
		return appUserSafeList;
	}

	public Map<String, Object>  executeAppUserSafeAuthenticate(String hpImei, String hpModel, String hpSNo, String appVer, String loginCo, String loginName, String loginUser, String loginPassword) {
		
		SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate);
		
		String procedureName = "SP_AppUser_Safe";
		
		simpleJdbcCall.withProcedureName(procedureName);
        SqlParameterSource inputParam = new MapSqlParameterSource()
        		.addValue("pi_HP_IMEI", hpImei)
        		.addValue("pi_HP_Model", hpModel)
        		.addValue("pi_HP_SNO", hpSNo)
        		.addValue("pi_APP_VER", appVer)
        		.addValue("pi_Login_Co", loginCo)
        		.addValue("pi_Login_Name", loginName)
        		.addValue("pi_Login_User", loginUser)
        		.addValue("pi_Login_Pass", loginPassword);

        Map<String, Object> out = simpleJdbcCall.execute(inputParam);
		return out;
	}
	
	public int insertAppUserSafe(AppUserSafe appUserSafe) {
		
		String queryString = "INSERT INTO APPUser_Safe (HP_IMEI, HP_SNO, Login_Co, Login_Name, Login_User, Login_Pass) VALUES (?, ?, ?, ?, ?, ?);";

        return jdbcTemplate.update(queryString, appUserSafe.getHpImei(), appUserSafe.getHpSNo(), appUserSafe.getLoginCo(), appUserSafe.getLoginName(), appUserSafe.getLoginName(), appUserSafe.getLoginPassword());
	}

	public int updateAppUserSafeForAppVersionAndLoginLastDateByHpImei(String appVersion, String loginLastDate, String hpImei) {
		
		String queryString = "UPDATE APPUser_Safe SET APP_VER = ?, Login_LastDate = ? WHERE HP_State = 'Y' AND HP_IMEI = ?";

        return jdbcTemplate.update(queryString, appVersion, loginLastDate, hpImei);
	}
}
