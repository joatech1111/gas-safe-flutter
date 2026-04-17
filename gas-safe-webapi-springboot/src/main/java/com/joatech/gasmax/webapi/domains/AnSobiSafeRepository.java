package com.joatech.gasmax.webapi.domains;

import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;

/*
 * 사용시설점검 Select View
 */
public class AnSobiSafeRepository extends GasMaxRepository{

	public AnSobiSafeRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}
	
	/*
	 * 사용시설 점검등록(SP_사용시설점검등록)
	 */
	public Map<String, Object> executeSaveAnSobiSafe(String saveDiv, String areaCode, String anzCuCode, String anzSno, String anzDate, String anzSwCode, String anzSwName,
													 float anzLpKg01, float anzLpKg02, String anzItem1, String anzItem1Sub, String anzItem1Text, String anzItem2, String anzItem2Sub,
													 String anzItem3, String anzItem3Sub, String anzItem3Text, String anzItem4, String anzItem4Sub,
													 String anzItem5, String anzItem5Sub, String anzItem5Text, String anzItem6, String anzItem6Sub,
													 String anzItem7, String anzItem7Sub, String anzItem8, String anzItem8Sub, String anzItem8Text,
													 String anzItem9, String anzItem9Sub, String anzItem9Text1, String anzItem9Text2, String anzItem10, 
													 String anzItem10Text1, String anzItem10Text2, String anzCuConfirm, String anzCuConfirmTel, String anzSignYn,
													 String gpsX, String gpsY, String anzUserId){
		
		
		SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate);
			
		String procedureName = "SP_SAVE_ANSOBI_SAFE";
		simpleJdbcCall.withProcedureName(procedureName);

	    SqlParameterSource inputParam = new MapSqlParameterSource()
	        		.addValue("pi_SAVE_DIV", saveDiv)
	        		.addValue("pi_Area_Code", areaCode)
	        		.addValue("pi_ANZ_Cu_Code", anzCuCode)
	        		.addValue("pi_ANZ_Sno", anzSno)
	        		.addValue("pi_ANZ_Date", anzDate)
	        		.addValue("pi_ANZ_SW_Code", anzSwCode)
	        		.addValue("pi_ANZ_SW_Name", anzSwName)
	        		.addValue("pi_ANZ_LP_KG_01", anzLpKg01)
	        		.addValue("pi_ANZ_LP_KG_02", anzLpKg02)
	        		.addValue("pi_ANZ_Item1", anzItem1)
	          		.addValue("pi_ANZ_Item1_SUB", anzItem1Sub)
	        		.addValue("pi_ANZ_Item1_Text", anzItem1Text)
	        		.addValue("pi_ANZ_Item2", anzItem2)
	          		.addValue("pi_ANZ_Item2_SUB", anzItem2Sub)
	        		.addValue("pi_ANZ_Item3", anzItem3)
	          		.addValue("pi_ANZ_Item3_SUB", anzItem3Sub)
	        		.addValue("pi_ANZ_Item3_Text", anzItem3Text)
	        		.addValue("pi_ANZ_Item4", anzItem4)
	          		.addValue("pi_ANZ_Item4_SUB", anzItem4Sub)
	        		.addValue("pi_ANZ_Item5", anzItem5)
	          		.addValue("pi_ANZ_Item5_SUB", anzItem5Sub)
	        		.addValue("pi_ANZ_Item5_Text", anzItem5Text)
	        		.addValue("pi_ANZ_Item6", anzItem6)
	          		.addValue("pi_ANZ_Item6_SUB", anzItem6Sub)
	        		.addValue("pi_ANZ_Item7", anzItem7)
	          		.addValue("pi_ANZ_Item7_SUB", anzItem7Sub)
	        		.addValue("pi_ANZ_Item8", anzItem8)
	          		.addValue("pi_ANZ_Item8_SUB", anzItem8Sub)
	        		.addValue("pi_ANZ_Item8_Text", anzItem8Text)
	        		.addValue("pi_ANZ_Item9", anzItem9)
	          		.addValue("pi_ANZ_Item9_SUB", anzItem9Sub)
	        		.addValue("pi_ANZ_Item9_Text1", anzItem9Text1)
	        		.addValue("pi_ANZ_Item9_Text2", anzItem9Text2)
	        		.addValue("pi_ANZ_Item10", anzItem10)
	        		.addValue("pi_ANZ_Item10_Text1", anzItem10Text1)
	        		.addValue("pi_ANZ_Item10_Text2", anzItem10Text2)
	          		.addValue("pi_ANZ_CU_Confirm", anzCuConfirm)  		
	          		.addValue("pi_ANZ_CU_Confirm_TEL", anzCuConfirmTel)
	          		.addValue("pi_ANZ_Sign_YN", anzSignYn)
	        		.addValue("pi_GPS_X", gpsX)
	        		.addValue("pi_GPS_Y", gpsY)
	        		.addValue("pi_ANZ_User_ID", anzUserId);
	
	    Map<String, Object> out = simpleJdbcCall.execute(inputParam);
	        
	    return out;
		
	}
	
	public List<Map<String, Object>> findSelectAnSobiSafeBy(String areaCode, String anzCucode, String anzSno) {

		String queryString = String.format("SELECT * FROM FN_SELECT_ANSOBI_SAFE('%s', '%s', '%s')", areaCode, anzCucode, anzSno);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findLastSelectAnSobiSafeBy(String areaCode, String anzCucode) {

		String queryString = String.format("SELECT * FROM FN_SELECT_ANSOBI_SAFE_LAST('%s', '%s', '')", areaCode, anzCucode);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}

}
