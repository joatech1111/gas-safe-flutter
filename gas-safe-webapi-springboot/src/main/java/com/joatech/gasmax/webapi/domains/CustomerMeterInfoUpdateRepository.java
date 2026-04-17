package com.joatech.gasmax.webapi.domains;

import java.util.Map;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;

/*
 * 거래처 검색/정보(SP 거래처 계량기 정보 수정)
 */
public class CustomerMeterInfoUpdateRepository extends GasMaxRepository {

	public CustomerMeterInfoUpdateRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}
	
	/*
	 * 거래처 검색/정보(SP 거래처 계량기 정보 수정)
	 */
	public Map<String, Object> executeCustomerMeterInfoUpdate(String areaCode, String cuCode, String cuGumTurm, String cuGumDate, String cuBarCode, String cuMeterNo,
																String cuMeterCo, String cuMeterLr, String cuMeterType, float cuMeterM3, String cuMeterDt, String appUser){
		
		SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate);
		
		String procedureName = "SP_CU_Meter_info_Update";
		simpleJdbcCall.withProcedureName(procedureName);
		
        SqlParameterSource inputParam = new MapSqlParameterSource()
        		.addValue("pi_AREA_CODE", areaCode)
        		.addValue("pi_CU_CODE", cuCode)
        		.addValue("pi_CU_Gum_Turm", cuGumTurm)
        		.addValue("pi_CU_GumDate", cuGumDate)
        		.addValue("pi_CU_Barcode", cuBarCode)
        		.addValue("pi_CU_Meter_No", cuMeterNo)
        		.addValue("pi_CU_Meter_Co", cuMeterCo)
        		.addValue("pi_CU_Meter_LR", cuMeterLr)
        		.addValue("pi_CU_Meter_TYPE", cuMeterType)
          		.addValue("pi_CU_Meter_M3", cuMeterM3)
        		.addValue("pi_CU_Meter_DT", cuMeterDt)
        		.addValue("pi_APP_User", appUser);

        Map<String, Object> out = simpleJdbcCall.execute(inputParam);
        
		return out;
	}

}
