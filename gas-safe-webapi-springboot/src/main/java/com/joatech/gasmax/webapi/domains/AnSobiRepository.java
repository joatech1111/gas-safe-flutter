package com.joatech.gasmax.webapi.domains;

import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;

/*
 * 소비설비 안전점검표 Select View(소비설비이력Select)
 */
public class AnSobiRepository extends GasMaxRepository{

	public AnSobiRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}
	
	/*
	 * 소비설비등록(SP_소비설비등록)
	 */
	public Map<String, Object> executeSaveAnSobi(String saveDiv, String areaCode, String anzCuCode, String anzSno, String anzDate, String anzSwCode, String anzSwName,
												 String anzCustName, String anzTel, String zipCode, String cuAddr1, String cuAddr2, String anzA01, String anzA02,
												 String anzA03, String anzA04, String anzA05, String anzB01, String anzB02, String anzB03, String anzB04, String anzB05,
												 String anzC01, String anzC02, String anzC03, String anzC04, String anzC05, String anzC06, String anzC07, String anzC08,
												 String anzGita01, String anzD01, String anzD02, String anzD03, String anzD04, String anzD05, String anzE01, String anzE02,
												 String anzE03, String anzE04, String anzF01, String anzF02, String anzF03, String anzF04, String anzG01, String anzG02,
												 String anzG03, String anzG04, String anzG05, String anzG06, String anzG07, String anzG08, String anzGita02, String anzGa,
												 String anzNa, String anzDa, String anzRa, String anzMa, String anzBa, String anzSa, String anzAa, String anzJa, String anzChaIn,
												 String anzCha, String anzCar, String anzGae01, String anzGae02, String anzGae03, String anzGae04, String anzGongDate, String anzCuConfirm,
												 String anzCuConfirmTel, String anzCuSmsYn, String anzGongNo, String anzGongName, String anzSignYn, String gpsX, String gpsY, String appUser){
		
		SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate);
		
		String procedureName = "SP_SAVE_ANSobi";
		simpleJdbcCall.withProcedureName(procedureName);
		
        SqlParameterSource inputParam = new MapSqlParameterSource()
        		.addValue("pi_SAVE_DIV", saveDiv)
        		.addValue("pi_Area_Code", areaCode)
        		.addValue("pi_ANZ_Cu_Code", anzCuCode)
        		.addValue("pi_ANZ_Sno", anzSno)
        		.addValue("pi_ANZ_Date", anzDate)
        		.addValue("pi_ANZ_SW_Code", anzSwCode)
        		.addValue("pi_ANZ_SW_Name", anzSwName)
        		.addValue("pi_ANZ_CustName", anzCustName)
        		.addValue("pi_ANZ_Tel", anzTel)
          		.addValue("pi_Zip_Code", zipCode)
        		.addValue("pi_CU_ADDR1", cuAddr1)
        		.addValue("pi_CU_ADDR2", cuAddr2)
        		.addValue("pi_ANZ_A_01", anzA01)
        		.addValue("pi_ANZ_A_02", anzA02)
        		.addValue("pi_ANZ_A_03", anzA03)
        		.addValue("pi_ANZ_A_04", anzA04)
        		.addValue("pi_ANZ_A_05", anzA05)
        		.addValue("pi_ANZ_B_01", anzB01)
        		.addValue("pi_ANZ_B_02", anzB02)
        		.addValue("pi_ANZ_B_03", anzB03)
        		.addValue("pi_ANZ_B_04", anzB04)
        		.addValue("pi_ANZ_B_05", anzB05)
        		.addValue("pi_ANZ_C_01", anzC01)
        		.addValue("pi_ANZ_C_02", anzC02)
        		.addValue("pi_ANZ_C_03", anzC03)
        		.addValue("pi_ANZ_C_04", anzC04)
        		.addValue("pi_ANZ_C_05", anzC05)
        		.addValue("pi_ANZ_C_06", anzC06)
        		.addValue("pi_ANZ_C_07", anzC07)
        		.addValue("pi_ANZ_C_08", anzC08)
        		.addValue("pi_ANZ_Gita_01", anzGita01)
         		.addValue("pi_ANZ_D_01", anzD01)
        		.addValue("pi_ANZ_D_02", anzD02)
        		.addValue("pi_ANZ_D_03", anzD03)
        		.addValue("pi_ANZ_D_04", anzD04)
        		.addValue("pi_ANZ_D_05", anzD05)
         		.addValue("pi_ANZ_E_01", anzE01)
        		.addValue("pi_ANZ_E_02", anzE02)
        		.addValue("pi_ANZ_E_03", anzE03)
        		.addValue("pi_ANZ_E_04", anzE04)
         		.addValue("pi_ANZ_F_01", anzF01)
        		.addValue("pi_ANZ_F_02", anzF02)
        		.addValue("pi_ANZ_F_03", anzF03)
        		.addValue("pi_ANZ_F_04", anzF04)
         		.addValue("pi_ANZ_G_01", anzG01)
        		.addValue("pi_ANZ_G_02", anzG02)
        		.addValue("pi_ANZ_G_03", anzG03)
        		.addValue("pi_ANZ_G_04", anzG04)
         		.addValue("pi_ANZ_G_05", anzG05)
        		.addValue("pi_ANZ_G_06", anzG06)
        		.addValue("pi_ANZ_G_07", anzG07)
        		.addValue("pi_ANZ_G_08", anzG08)
        		.addValue("pi_ANZ_Gita_02", anzGita02)
        		.addValue("pi_ANZ_Ga", anzGa)
        		.addValue("pi_ANZ_Na", anzNa)
        		.addValue("pi_ANZ_Da", anzDa)
        		.addValue("pi_ANZ_Ra", anzRa)
        		.addValue("pi_ANZ_Ma", anzMa)
        		.addValue("pi_ANZ_Ba", anzBa)
        		.addValue("pi_ANZ_Sa", anzSa)
        		.addValue("pi_ANZ_AA", anzAa)
        		.addValue("pi_ANZ_JA", anzJa)
        		.addValue("pi_ANZ_Cha_IN", anzChaIn)
        		.addValue("pi_ANZ_Cha", anzCha)
        		.addValue("pi_ANZ_Car", anzCar)
        		.addValue("pi_ANZ_Gae_01", anzGae01)
        		.addValue("pi_ANZ_Gae_02", anzGae02)
        		.addValue("pi_ANZ_Gae_03", anzGae03)
        		.addValue("pi_ANZ_Gae_04", anzGae04)
        		.addValue("pi_ANZ_GongDate", anzGongDate)
        		.addValue("pi_ANZ_CU_Confirm", anzCuConfirm)
          		.addValue("pi_ANZ_CU_Confirm_TEL", anzCuConfirmTel)
        		.addValue("pi_ANZ_CU_SMS_YN", anzCuSmsYn)
          		.addValue("pi_ANZ_GongNo", anzGongNo)
        		.addValue("pi_ANZ_GongName", anzGongName)
          		.addValue("pi_ANZ_Sign_YN", anzSignYn)
        		.addValue("pi_GPS_X", gpsX)
        		.addValue("pi_GPS_Y", gpsY)
        		.addValue("pi_ANZ_APP_User", appUser);

        Map<String, Object> out = simpleJdbcCall.execute(inputParam);
        
		return out;
		
	}

/*
	 * 소비설비등록(SP_소비설비등록)
	 */
	public Map<String, Object> executeSaveAnSobiNew(String saveDiv, String areaCode, String anzCuCode, String anzSno, String anzDate, String anzSwCode, String anzSwName,
												 String anzCustName, String anzTel, String zipCode, String cuAddr1, String cuAddr2, String anzA01, String anzA02,
												 String anzA03, String anzA04, String anzA05, String anzB01, String anzB02, String anzB03, String anzB04, String anzB05,
												 String anzC01, String anzC02, String anzC03, String anzC04, String anzC05, String anzC06, String anzC07, String anzC08,
												 String anzGita01, String anzD01, String anzD02, String anzD03, String anzD04, String anzD05, String anzE01, String anzE02,
												 String anzE03, String anzE04, String anzF01, String anzF02, String anzF03, String anzF04, String anzG01, String anzG02,
												 String anzG03, String anzG04, String anzG05, String anzG06, String anzG07, String anzG08, String anzGita02, String anzGa,
												 String anzNa, String anzDa, String anzRa, String anzMa, String anzBa, String anzSa, String anzAa, String anzJa,
												 String anzCha, String anzCar, String anzCarIn, String anzGae01, String anzGae02, String anzGae03, String anzGae04, String anzGongDate, String anzCuConfirm,
												 String anzCuConfirmTel, String anzCuSmsYn, String anzGongNo, String anzGongName, String anzSignYn, String gpsX, String gpsY, String appUser,
												 String anzFinishDate, String anzCircuitDate){
		
		SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate);
		
		String procedureName = "SP_SAVE_ANSobi_2";
		simpleJdbcCall.withProcedureName(procedureName);
		
        SqlParameterSource inputParam = new MapSqlParameterSource()
        		.addValue("pi_SAVE_DIV", saveDiv)
        		.addValue("pi_Area_Code", areaCode)
        		.addValue("pi_ANZ_Cu_Code", anzCuCode)
        		.addValue("pi_ANZ_Sno", anzSno)
        		.addValue("pi_ANZ_Date", anzDate)
        		.addValue("pi_ANZ_SW_Code", anzSwCode)
        		.addValue("pi_ANZ_SW_Name", anzSwName)
        		.addValue("pi_ANZ_CustName", anzCustName)
        		.addValue("pi_ANZ_Tel", anzTel)
          		.addValue("pi_Zip_Code", zipCode)
        		.addValue("pi_CU_ADDR1", cuAddr1)
        		.addValue("pi_CU_ADDR2", cuAddr2)
        		.addValue("pi_ANZ_A_01", anzA01)
        		.addValue("pi_ANZ_A_02", anzA02)
        		.addValue("pi_ANZ_A_03", anzA03)
        		.addValue("pi_ANZ_A_04", anzA04)
        		.addValue("pi_ANZ_A_05", anzA05)
        		.addValue("pi_ANZ_B_01", anzB01)
        		.addValue("pi_ANZ_B_02", anzB02)
        		.addValue("pi_ANZ_B_03", anzB03)
        		.addValue("pi_ANZ_B_04", anzB04)
        		.addValue("pi_ANZ_B_05", anzB05)
        		.addValue("pi_ANZ_C_01", anzC01)
        		.addValue("pi_ANZ_C_02", anzC02)
        		.addValue("pi_ANZ_C_03", anzC03)
        		.addValue("pi_ANZ_C_04", anzC04)
        		.addValue("pi_ANZ_C_05", anzC05)
        		.addValue("pi_ANZ_C_06", anzC06)
        		.addValue("pi_ANZ_C_07", anzC07)
        		.addValue("pi_ANZ_C_08", anzC08)
        		.addValue("pi_ANZ_Gita_01", anzGita01)
         		.addValue("pi_ANZ_D_01", anzD01)
        		.addValue("pi_ANZ_D_02", anzD02)
        		.addValue("pi_ANZ_D_03", anzD03)
        		.addValue("pi_ANZ_D_04", anzD04)
        		.addValue("pi_ANZ_D_05", anzD05)
         		.addValue("pi_ANZ_E_01", anzE01)
        		.addValue("pi_ANZ_E_02", anzE02)
        		.addValue("pi_ANZ_E_03", anzE03)
        		.addValue("pi_ANZ_E_04", anzE04)
         		.addValue("pi_ANZ_F_01", anzF01)
        		.addValue("pi_ANZ_F_02", anzF02)
        		.addValue("pi_ANZ_F_03", anzF03)
        		.addValue("pi_ANZ_F_04", anzF04)
         		.addValue("pi_ANZ_G_01", anzG01)
        		.addValue("pi_ANZ_G_02", anzG02)
        		.addValue("pi_ANZ_G_03", anzG03)
        		.addValue("pi_ANZ_G_04", anzG04)
         		.addValue("pi_ANZ_G_05", anzG05)
        		.addValue("pi_ANZ_G_06", anzG06)
        		.addValue("pi_ANZ_G_07", anzG07)
        		.addValue("pi_ANZ_G_08", anzG08)
        		.addValue("pi_ANZ_Gita_02", anzGita02)
        		.addValue("pi_ANZ_Ga", anzGa)
        		.addValue("pi_ANZ_Na", anzNa)
        		.addValue("pi_ANZ_Da", anzDa)
        		.addValue("pi_ANZ_Ra", anzRa)
        		.addValue("pi_ANZ_Ma", anzMa)
        		.addValue("pi_ANZ_Ba", anzBa)
        		.addValue("pi_ANZ_Sa", anzSa)
        		.addValue("pi_ANZ_AA", anzAa)
        		.addValue("pi_ANZ_JA", anzJa)
        		.addValue("pi_ANZ_Cha", anzCha)
        		.addValue("pi_ANZ_Car", anzCar)
				.addValue("pi_ANZ_Car_IN", anzCarIn)
        		.addValue("pi_ANZ_Gae_01", anzGae01)
        		.addValue("pi_ANZ_Gae_02", anzGae02)
        		.addValue("pi_ANZ_Gae_03", anzGae03)
        		.addValue("pi_ANZ_Gae_04", anzGae04)
        		.addValue("pi_ANZ_GongDate", anzGongDate)
        		.addValue("pi_ANZ_CU_Confirm", anzCuConfirm)
          		.addValue("pi_ANZ_CU_Confirm_TEL", anzCuConfirmTel)
        		.addValue("pi_ANZ_CU_SMS_YN", anzCuSmsYn)
          		.addValue("pi_ANZ_GongNo", anzGongNo)
        		.addValue("pi_ANZ_GongName", anzGongName)
          		.addValue("pi_ANZ_Sign_YN", anzSignYn)
        		.addValue("pi_GPS_X", gpsX)
        		.addValue("pi_GPS_Y", gpsY)
        		.addValue("pi_ANZ_APP_User", appUser)
        		.addValue("pi_Finish_DATE", anzFinishDate) 
        		.addValue("pi_CirCuit_DATE",anzCircuitDate);

        Map<String, Object> out = simpleJdbcCall.execute(inputParam);
        
		return out;
		
	}


	public Map<String, Object> executeSaveAnSobiNewAdd(String saveDiv, String areaCode, String anzCuCode, String anzSno, String anzDate, String anzSwCode, String anzSwName,
													String anzCustName, String anzTel, String zipCode, String cuAddr1, String cuAddr2, String anzA01, String anzA02,
													String anzA03, String anzA04, String anzA05, String anzB01, String anzB02, String anzB03, String anzB04, String anzB05,
													String anzC01, String anzC02, String anzC03, String anzC04, String anzC05, String anzC06, String anzC07, String anzC08,
													String anzGita01, String anzD01, String anzD02, String anzD03, String anzD04, String anzD05, String anzE01, String anzE02,
													String anzE03, String anzE04, String anzF01, String anzF02, String anzF03, String anzF04, String anzG01, String anzG02,
													String anzG03, String anzG04, String anzG05, String anzG06, String anzG07, String anzG08, String anzGita02, String anzGa,
													String anzNa, String anzDa, String anzRa, String anzMa, String anzBa, String anzSa, String anzAa, String anzJa, String anzChaIn,
													String anzCha, String anzCar, String anzCarIn, String anzGae01, String anzGae02, String anzGae03, String anzGae04, String anzGongDate, String anzCuConfirm,
													String anzCuConfirmTel, String anzCuSmsYn, String anzGongNo, String anzGongName, String anzSignYn, String gpsX, String gpsY, String appUser,
													String anzFinishDate, String anzCircuitDate, String contFileUrl){

		SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate);

		String procedureName = "SP_SAVE_ANSobi_3";
		simpleJdbcCall.withProcedureName(procedureName);

		SqlParameterSource inputParam = new MapSqlParameterSource()
				.addValue("pi_SAVE_DIV", saveDiv)
				.addValue("pi_Area_Code", areaCode)
				.addValue("pi_ANZ_Cu_Code", anzCuCode)
				.addValue("pi_ANZ_Sno", anzSno)
				.addValue("pi_ANZ_Date", anzDate)
				.addValue("pi_ANZ_SW_Code", anzSwCode)
				.addValue("pi_ANZ_SW_Name", anzSwName)
				.addValue("pi_ANZ_CustName", anzCustName)
				.addValue("pi_ANZ_Tel", anzTel)
				.addValue("pi_Zip_Code", zipCode)
				.addValue("pi_CU_ADDR1", cuAddr1)
				.addValue("pi_CU_ADDR2", cuAddr2)
				.addValue("pi_ANZ_A_01", anzA01)
				.addValue("pi_ANZ_A_02", anzA02)
				.addValue("pi_ANZ_A_03", anzA03)
				.addValue("pi_ANZ_A_04", anzA04)
				.addValue("pi_ANZ_A_05", anzA05)
				.addValue("pi_ANZ_B_01", anzB01)
				.addValue("pi_ANZ_B_02", anzB02)
				.addValue("pi_ANZ_B_03", anzB03)
				.addValue("pi_ANZ_B_04", anzB04)
				.addValue("pi_ANZ_B_05", anzB05)
				.addValue("pi_ANZ_C_01", anzC01)
				.addValue("pi_ANZ_C_02", anzC02)
				.addValue("pi_ANZ_C_03", anzC03)
				.addValue("pi_ANZ_C_04", anzC04)
				.addValue("pi_ANZ_C_05", anzC05)
				.addValue("pi_ANZ_C_06", anzC06)
				.addValue("pi_ANZ_C_07", anzC07)
				.addValue("pi_ANZ_C_08", anzC08)
				.addValue("pi_ANZ_Gita_01", anzGita01)
				.addValue("pi_ANZ_D_01", anzD01)
				.addValue("pi_ANZ_D_02", anzD02)
				.addValue("pi_ANZ_D_03", anzD03)
				.addValue("pi_ANZ_D_04", anzD04)
				.addValue("pi_ANZ_D_05", anzD05)
				.addValue("pi_ANZ_E_01", anzE01)
				.addValue("pi_ANZ_E_02", anzE02)
				.addValue("pi_ANZ_E_03", anzE03)
				.addValue("pi_ANZ_E_04", anzE04)
				.addValue("pi_ANZ_F_01", anzF01)
				.addValue("pi_ANZ_F_02", anzF02)
				.addValue("pi_ANZ_F_03", anzF03)
				.addValue("pi_ANZ_F_04", anzF04)
				.addValue("pi_ANZ_G_01", anzG01)
				.addValue("pi_ANZ_G_02", anzG02)
				.addValue("pi_ANZ_G_03", anzG03)
				.addValue("pi_ANZ_G_04", anzG04)
				.addValue("pi_ANZ_G_05", anzG05)
				.addValue("pi_ANZ_G_06", anzG06)
				.addValue("pi_ANZ_G_07", anzG07)
				.addValue("pi_ANZ_G_08", anzG08)
				.addValue("pi_ANZ_Gita_02", anzGita02)
				.addValue("pi_ANZ_Ga", anzGa)
				.addValue("pi_ANZ_Na", anzNa)
				.addValue("pi_ANZ_Da", anzDa)
				.addValue("pi_ANZ_Ra", anzRa)
				.addValue("pi_ANZ_Ma", anzMa)
				.addValue("pi_ANZ_Ba", anzBa)
				.addValue("pi_ANZ_Sa", anzSa)
				.addValue("pi_ANZ_AA", anzAa)
				.addValue("pi_ANZ_JA", anzJa)
				.addValue("pi_ANZ_Cha_IN", anzChaIn)
				.addValue("pi_ANZ_Cha", anzCha)
				.addValue("pi_ANZ_Car", anzCar)
				.addValue("pi_ANZ_Car_IN", anzCarIn)
				.addValue("pi_ANZ_Gae_01", anzGae01)
				.addValue("pi_ANZ_Gae_02", anzGae02)
				.addValue("pi_ANZ_Gae_03", anzGae03)
				.addValue("pi_ANZ_Gae_04", anzGae04)
				.addValue("pi_ANZ_GongDate", anzGongDate)
				.addValue("pi_ANZ_CU_Confirm", anzCuConfirm)
				.addValue("pi_ANZ_CU_Confirm_TEL", anzCuConfirmTel)
				.addValue("pi_ANZ_CU_SMS_YN", anzCuSmsYn)
				.addValue("pi_ANZ_GongNo", anzGongNo)
				.addValue("pi_ANZ_GongName", anzGongName)
				.addValue("pi_ANZ_Sign_YN", anzSignYn)
				.addValue("pi_GPS_X", gpsX)
				.addValue("pi_GPS_Y", gpsY)
				.addValue("pi_ANZ_APP_User", appUser)
				.addValue("pi_Finish_DATE", anzFinishDate)
				.addValue("pi_CirCuit_DATE",anzCircuitDate)
				.addValue("pi_CONT_FILE_URL", contFileUrl);

		Map<String, Object> out = simpleJdbcCall.execute(inputParam);

		return out;

	}


	public List<Map<String, Object>> findAllAnSobiBy(String areaCode, String anzCuCode, String anzSno){ 

		String queryString = String.format("SELECT * FROM FN_SELECT_ANSOBI('%s', '%s', '%s')", areaCode, anzCuCode, anzSno);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}

	public List<Map<String, Object>> findAll3AnSobiBy(String areaCode, String anzCuCode, String anzSno){

		String queryString = String.format("SELECT * FROM FN_SELECT_ANSOBI_3('%s', '%s', '%s')", areaCode, anzCuCode, anzSno);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}

	public List<Map<String, Object>> findLastAnSobiBy(String areaCode, String anzCuCode){ 

		String queryString = String.format("SELECT * FROM FN_SELECT_ANSOBI_LAST('%s', '%s', '')", areaCode, anzCuCode);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}

	public List<Map<String, Object>> findLast3AnSobiBy(String areaCode, String anzCuCode){

		String queryString = String.format("SELECT * FROM FN_SELECT_ANSOBI_LAST_3('%s', '%s', '')", areaCode, anzCuCode);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}


}
