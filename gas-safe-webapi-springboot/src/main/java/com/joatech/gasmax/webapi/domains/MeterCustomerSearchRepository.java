package com.joatech.gasmax.webapi.domains;

import java.util.List;
import java.util.Map;

/*
 * 검침 거래처 검색(FN_검침 거래처 검색)
 */
public class MeterCustomerSearchRepository extends GasMaxRepository {

	public MeterCustomerSearchRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}

	
	public List<Map<String, Object>> findAllMeterCustomerBy(String areaCode, String findStr, String gumDate,
				String suppYN, String gumYMSNo, String gumTerm, String gumMMDD, String cuCode, String aptCd, String swCd,
				String manCd, String jyCd, String addrText, String smartMeterYN, String gpsX, String gpsY) { 
		  String queryString = String.format(
				  "SELECT * FROM FN_METER_CU_FIND_ALL('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')"
	              , areaCode, findStr, gumDate, suppYN, gumYMSNo, gumTerm, gumMMDD, cuCode, aptCd, swCd, manCd, jyCd, 
	              addrText, smartMeterYN, gpsX, gpsY);
	      List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
	      return result; 
	}
	
	public List<Map<String, Object>> findAllMeterCustomerByOrderBy(String areaCode, String findStr, String gumDate,
			String suppYN, String gumYMSNo, String gumTerm, String gumMMDD, String cuCode, String aptCd, String swCd,
			String manCd, String jyCd, String addrText, String smartMeterYN, String gpsX, String gpsY, String orderBy) { 
	  String queryString = String.format(
			  "SELECT * FROM FN_METER_CU_FIND_ALL('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ORDER BY %s"
              , areaCode, findStr, gumDate, suppYN, gumYMSNo, gumTerm, gumMMDD, cuCode, aptCd, swCd, manCd, jyCd, 
              addrText, smartMeterYN, gpsX, gpsY, orderBy);
      List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
      return result; 
	}
	 

	public List<Map<String, Object>> findSNoMeterCustomerBy(String areaCode, String findStr, String gumDate,
			String suppYN, String gumYMSNo, String gumTerm, String gumMMDD, String cuCode, String aptCd, String swCd,
			String manCd, String jyCd, String addrText, String smartMeterYN, String gpsX, String gpsY) {
		String queryString = String.format(
				"SELECT * FROM FN_METER_CU_FIND_SNO('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')",
				areaCode, findStr, gumDate, suppYN, gumYMSNo, gumTerm, gumMMDD, cuCode, aptCd, swCd, manCd, jyCd,
				addrText, smartMeterYN, gpsX, gpsY);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findSNoMeterCustomerByOrderBy(String areaCode, String findStr, String gumDate,
			String suppYN, String gumYMSNo, String gumTerm, String gumMMDD, String cuCode, String aptCd, String swCd,
			String manCd, String jyCd, String addrText, String smartMeterYN, String gpsX, String gpsY, String orderBy) {
		String queryString = String.format(
				"SELECT * FROM FN_METER_CU_FIND_SNO('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ORDER BY %s",
				areaCode, findStr, gumDate, suppYN, gumYMSNo, gumTerm, gumMMDD, cuCode, aptCd, swCd, manCd, jyCd,
				addrText, smartMeterYN, gpsX, gpsY, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}

	public List<Map<String, Object>> findTurmMeterCustomerBy(String areaCode, String findStr, String gumDate,
			String suppYN, String gumYMSNo, String gumTerm, String gumMMDD, String cuCode, String aptCd, String swCd,
			String manCd, String jyCd, String addrText, String smartMeterYN, String gpsX, String gpsY) {
		String queryString = String.format(
				"SELECT * FROM FN_METER_CU_FIND_TURM('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')",
				areaCode, findStr, gumDate, suppYN, gumYMSNo, gumTerm, gumMMDD, cuCode, aptCd, swCd, manCd, jyCd,
				addrText, smartMeterYN, gpsX, gpsY);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findTurmMeterCustomerByOrderBy(String areaCode, String findStr, String gumDate,
			String suppYN, String gumYMSNo, String gumTerm, String gumMMDD, String cuCode, String aptCd, String swCd,
			String manCd, String jyCd, String addrText, String smartMeterYN, String gpsX, String gpsY, String orderBy) {
		String queryString = String.format(
				"SELECT * FROM FN_METER_CU_FIND_TURM('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ORDER BY %s",
				areaCode, findStr, gumDate, suppYN, gumYMSNo, gumTerm, gumMMDD, cuCode, aptCd, swCd, manCd, jyCd,
				addrText, smartMeterYN, gpsX, gpsY, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}

	public List<Map<String, Object>> findGpsMeterCustomerBy(String areaCode, String findStr, String gumDate,
			String suppYN, String gumYMSNo, String gumTerm, String gumMMDD, String cuCode, String aptCd, String swCd,
			String manCd, String jyCd, String addrText, String smartMeterYN, String gpsX, String gpsY) {
		String queryString = String.format(
				"SELECT * FROM FN_METER_CU_FIND_GPS('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')",
				areaCode, findStr, gumDate, suppYN, gumYMSNo, gumTerm, gumMMDD, cuCode, aptCd, swCd, manCd, jyCd,
				addrText, smartMeterYN, gpsX, gpsY);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findGpsMeterCustomerByOrderBy(String areaCode, String findStr, String gumDate,
			String suppYN, String gumYMSNo, String gumTerm, String gumMMDD, String cuCode, String aptCd, String swCd,
			String manCd, String jyCd, String addrText, String smartMeterYN, String gpsX, String gpsY, String orderBy) {
		String queryString = String.format(
				"SELECT * FROM FN_METER_CU_FIND_GPS('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ORDER BY %s",
				areaCode, findStr, gumDate, suppYN, gumYMSNo, gumTerm, gumMMDD, cuCode, aptCd, swCd, manCd, jyCd,
				addrText, smartMeterYN, gpsX, gpsY, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
}
