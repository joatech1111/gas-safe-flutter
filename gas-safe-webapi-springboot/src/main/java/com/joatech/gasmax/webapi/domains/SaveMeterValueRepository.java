package com.joatech.gasmax.webapi.domains;

import java.util.Map;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;

/*
 * 체적검침등록(SP 검친등록)
 */
public class SaveMeterValueRepository extends GasMaxRepository {

	public SaveMeterValueRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}
	
	public Map<String, Object> executeSaveMeterValue(String saveDiv, String areaCode, String cuCode, String gjDate, String gjGumYm, String cuName, String cuUserName, int gjJunGum,
										int gjGum, int gjGage, int gjT1Per, int gjT1Kg, int gjT2Per, int gjT2Kg, int gjJanKg, String gjBigo, String safeSwCode,
										String safeSwName, String gpsX, String gpsY, String appUser) {
		
		SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate);
		
		String procedureName = "SP_SAVE_METER_VALUE";
		
		simpleJdbcCall.withProcedureName(procedureName);
        SqlParameterSource inputParam = new MapSqlParameterSource()
        		.addValue("pi_SAVE_DIV", saveDiv)
        		.addValue("pi_AREA_CODE", areaCode)
        		.addValue("pi_CU_CODE", cuCode)
        		.addValue("pi_GJ_DATE", gjDate)
        		.addValue("pi_GJ_GUM_YM", gjGumYm)
        		.addValue("pi_CU_NAME", cuName)
        		.addValue("pi_CU_USERNAME", cuUserName)
        		.addValue("pi_GJ_JUNGUM", gjJunGum)
        		.addValue("pi_GJ_GUM", gjGum)
        		.addValue("pi_GJ_GAGE", gjGage)
        		.addValue("pi_GJ_T1_Per", gjT1Per)
        		.addValue("pi_GJ_T1_kg", gjT1Kg)
        		.addValue("pi_GJ_T2_Per", gjT2Per)
        		.addValue("pi_GJ_T2_kg", gjT2Kg)
        		.addValue("pi_GJ_JANKG", gjJanKg)
        		.addValue("pi_GJ_BIGO", gjBigo)
        		.addValue("pi_SAFE_SW_CODE", safeSwCode)
        		.addValue("pi_SAFE_SW_NAME", safeSwName)
        		.addValue("pi_GPS_X", gpsX)
        		.addValue("pi_GPS_Y", gpsY)
        		.addValue("pi_APP_User", appUser);

        Map<String, Object> result = simpleJdbcCall.execute(inputParam);
        
		return result;
	}

}
