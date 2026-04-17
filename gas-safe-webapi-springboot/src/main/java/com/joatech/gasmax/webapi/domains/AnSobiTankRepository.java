package com.joatech.gasmax.webapi.domains;

import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;

/*
 * 저장탱크 안전점검표 Select View(탱크 점검 Select)
 */
public class AnSobiTankRepository extends GasMaxRepository {

	public AnSobiTankRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}
	
	/*
	 *저장탱크 안전점검표(SP 탱크시설 점검등록)
	 */
	public Map<String, Object> executeSaveAnSobiTank(String saveDiv, String areaCode, String anzCuCode, String anzSno, String anzDate, String anzSwCode, String anzSwName,
													float anzTankKg01, float anzTankKg02, String anzTank01, String anzTank01Bigo, String anzTank02, String anzTank02Bigo,
													String anzTank03, String anzTank03Bigo, String anzTank04, String anzTank04Bigo, String anzTank05, String anzTank05Bigo,
													String anzTank06, String anzTank06Bigo, String anzTank07, String anzTank07Bigo, String anzTank08, String anzTank08Bigo, 
													String anzTank09, String anzTank09Bigo, String anzcheckItem10, String anzTank10, String anzTank10Bigo, String anzcheckItem11,
													String anzTank11, String anzTank11Bigo, String anzcheckItem12, String anzTank12, String anzTank12Bigo, String anzTankSwBigo1,
													String anzTankSwBigo2, String anzCustName, String anzSignYn, String anzCuConfirm, String anzCuConfirmTel, String gpsX, String gpsY, 
													String anzUserId){
		
		SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate);
		
		String procedureName = "SP_SAVE_ANSobi_TANK";
		simpleJdbcCall.withProcedureName(procedureName);
		
        SqlParameterSource inputParam = new MapSqlParameterSource()
        		.addValue("pi_SAVE_DIV", saveDiv)
        		.addValue("pi_Area_Code", areaCode)
        		.addValue("pi_ANZ_Cu_Code", anzCuCode)
        		.addValue("pi_ANZ_Sno", anzSno)
        		.addValue("pi_ANZ_Date", anzDate)
        		.addValue("pi_ANZ_SW_Code", anzSwCode)
        		.addValue("pi_ANZ_SW_Name", anzSwName)
        		.addValue("pi_ANZ_TANK_KG_01", anzTankKg01)
        		.addValue("pi_ANZ_TANK_KG_02", anzTankKg02)
        		.addValue("pi_ANZ_TANK_01", anzTank01)
          		.addValue("pi_ANZ_TANK_01_Bigo", anzTank01Bigo)
        		.addValue("pi_ANZ_TANK_02", anzTank02)
          		.addValue("pi_ANZ_TANK_02_Bigo", anzTank02Bigo)
        		.addValue("pi_ANZ_TANK_03", anzTank03)
          		.addValue("pi_ANZ_TANK_03_Bigo", anzTank03Bigo)
        		.addValue("pi_ANZ_TANK_04", anzTank04)
          		.addValue("pi_ANZ_TANK_04_Bigo", anzTank04Bigo)
        		.addValue("pi_ANZ_TANK_05", anzTank05)
          		.addValue("pi_ANZ_TANK_05_Bigo", anzTank05Bigo)
        		.addValue("pi_ANZ_TANK_06", anzTank06)
          		.addValue("pi_ANZ_TANK_06_Bigo", anzTank06Bigo)
        		.addValue("pi_ANZ_TANK_07", anzTank07)
          		.addValue("pi_ANZ_TANK_07_Bigo", anzTank07Bigo)
        		.addValue("pi_ANZ_TANK_08", anzTank08)
          		.addValue("pi_ANZ_TANK_08_Bigo", anzTank08Bigo)
        		.addValue("pi_ANZ_TANK_09", anzTank09)
          		.addValue("pi_ANZ_TANK_09_Bigo", anzTank09Bigo)
        		.addValue("pi_ANZ_Check_item_10", anzcheckItem10)
         		.addValue("pi_ANZ_TANK_10", anzTank10)
          		.addValue("pi_ANZ_TANK_10_Bigo", anzTank10Bigo)
        		.addValue("pi_ANZ_Check_item_11", anzcheckItem11)
         		.addValue("pi_ANZ_TANK_11", anzTank11)
          		.addValue("pi_ANZ_TANK_11_Bigo", anzTank11Bigo)
        		.addValue("pi_ANZ_Check_item_12", anzcheckItem12)
         		.addValue("pi_ANZ_TANK_12", anzTank12)
          		.addValue("pi_ANZ_TANK_12_Bigo", anzTank12Bigo)
           		.addValue("pi_ANZ_TANK_SW_Bigo1", anzTankSwBigo1)
         		.addValue("pi_ANZ_TANK_SW_Bigo2", anzTankSwBigo2)
          		.addValue("pi_ANZ_CustName", anzCustName)
          		.addValue("pi_ANZ_Sign_YN", anzSignYn)
          		.addValue("pi_ANZ_CU_Confirm", anzCuConfirm)
          		.addValue("pi_ANZ_CU_Confirm_TEL", anzCuConfirmTel)
        		.addValue("pi_GPS_X", gpsX)
        		.addValue("pi_GPS_Y", gpsY)
        		.addValue("pi_ANZ_User_ID", anzUserId);

        Map<String, Object> out = simpleJdbcCall.execute(inputParam);
        
		return out;
		
	}
	
	public List<Map<String, Object>> findAnSobiTankBy(String areaCode, String anzCucode, String anzSno) {

		String queryString = String.format("SELECT * FROM FN_SELECT_ANSOBI_TANK('%s', '%s', '%s')", areaCode, anzCucode, anzSno);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findLastAnSobiTankBy(String areaCode, String anzCucode) {

		String queryString = String.format("SELECT * FROM FN_SELECT_ANSOBI_TANK_LAST('%s', '%s', '')", areaCode, anzCucode);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	

}
