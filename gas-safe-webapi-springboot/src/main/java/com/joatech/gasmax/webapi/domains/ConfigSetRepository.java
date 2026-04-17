package com.joatech.gasmax.webapi.domains;

import java.util.Map;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;

/*
 * 환경설정 저장(SP 환경저장)
 */
public class ConfigSetRepository extends GasMaxRepository{

	public ConfigSetRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}
	
	/*
	 * 환경 설정 저장(SP 환경 저장)
	 */
	public Map<String, Object> executeConfigSet(String hpImei, String loginUser, String loginPass, String safeSwCode, String areaCode, String swCode, String gubunCode, String jyCode, String orderBy) {
		SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate);
		
		String procedureName = "SP_SAVE_DEFULT_SET";
		
		simpleJdbcCall.withProcedureName(procedureName);
        SqlParameterSource inputParam = new MapSqlParameterSource()
        		.addValue("pi_HP_IMEI", hpImei)
        		.addValue("pi_Login_User", loginUser)
        		.addValue("pi_Login_Pass", loginPass)
        		.addValue("pi_Safe_SW_CODE", safeSwCode)
        		.addValue("pi_Area_CODE", areaCode)
        		.addValue("pi_SW_CODE", swCode)
        		.addValue("pi_Gubun_CODE", gubunCode)
        		.addValue("pi_JY_Code", jyCode)
        		.addValue("pi_OrderBy", orderBy);

        Map<String, Object> out = simpleJdbcCall.execute(inputParam);
        
		return out;
	}
		
}
