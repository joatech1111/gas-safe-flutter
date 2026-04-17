package com.joatech.gasmax.webapi.domains;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.jdbc.core.RowMapper;

/**
 * 거래처 검색/정보
 */
public class CustomerInfoRepository extends GasMaxRepository {

	public CustomerInfoRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}

	/**
	 * ✅ 거래처 단건 조회 (MeterInsertRepository 스타일)
	 */
	public CustomerInfo selectCustomerInfo(String areaCode, String cuCode) {
		String query = "SELECT * FROM CUSTOMER WHERE AREA_CODE = ? AND CU_CODE = ?";

		try {
			List<CustomerInfo> resultList = jdbcTemplate.query(query, new Object[]{areaCode, cuCode}, new RowMapper<CustomerInfo>() {
				@Override
				public CustomerInfo mapRow(ResultSet rs, int rowNum) throws SQLException {
					CustomerInfo customerInfo = new CustomerInfo();
					customerInfo.setAreaCode(rs.getString("AREA_CODE"));
					customerInfo.setCuCode(rs.getString("CU_CODE"));
					customerInfo.setCuType(rs.getString("CU_TYPE")); // ✅ 수정
					customerInfo.setCuName(rs.getString("CU_NAME"));
					customerInfo.setCuUserName(rs.getString("CU_USERNAME"));
					customerInfo.setCuTel(rs.getString("CU_TEL"));
					customerInfo.setCuHp(rs.getString("CU_HP"));
					customerInfo.setZipCode(rs.getString("CU_ZIPCODE")); // ✅ 수정
					customerInfo.setCuAddr1(rs.getString("CU_ADDR1"));
					customerInfo.setCuAddr2(rs.getString("CU_ADDR2"));
					customerInfo.setCuBigo1(rs.getString("CU_BIGO1"));
					customerInfo.setCuBigo2(rs.getString("CU_BIGO2"));
					customerInfo.setCuSwCode(rs.getString("CU_SW_CODE"));
					customerInfo.setCuSwName(rs.getString("CU_SW_NAME"));
					customerInfo.setCuCuType(rs.getString("CU_CUTYPE"));
					customerInfo.setGpsX(rs.getString("CU_GPS_X")); // ✅ 수정
					customerInfo.setGpsY(rs.getString("CU_GPS_Y")); // ✅ 수정
					customerInfo.setAppUser(rs.getString("CU_APP_User")); // ✅ 수정
					return customerInfo;
				}
			});

			return resultList.isEmpty() ? null : resultList.get(0);

		} catch (Exception e) {
			// Log properly or throw custom exception if needed
			System.err.println("❌ Failed to select customer info: " + e.getMessage());
		}

		return null;
	}


	/**
	 * ✅ 거래처 수정 (SP 호출)
	 */
	public Map<String, Object> executeCustomerEditSafe(
			String div, String areaCode, String cuCode, String cuType, String cuName, String cuUserName,
			String cuTel, String cuTelFind, String cuHp, String cuHpFind, String zipCode, String cuAddr1, String cuAddr2,
			String cuBigo1, String cuBigo2, String cuSwCode, String cuSwName, String cuCuType, String gpsX, String gpsY,
			String appUser) {

		SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
				.withProcedureName("sp_CUST_EDIT_SAFE");

		SqlParameterSource inputParam = new MapSqlParameterSource()
				.addValue("pi_DIV", div)
				.addValue("pi_AREA_CODE", areaCode)
				.addValue("pi_CU_CODE", cuCode)
				.addValue("pi_CU_Type", cuType)
				.addValue("pi_CU_NAME", cuName)
				.addValue("pi_CU_USERNAME", cuUserName)
				.addValue("pi_CU_TEL", cuTel)
				.addValue("pi_CU_TELFIND", cuTelFind)
				.addValue("pi_CU_HP", cuHp)
				.addValue("pi_CU_HPFIND", cuHpFind)
				.addValue("pi_Zip_Code", zipCode)
				.addValue("pi_CU_ADDR1", cuAddr1)
				.addValue("pi_CU_ADDR2", cuAddr2)
				.addValue("pi_CU_Bigo1", cuBigo1)
				.addValue("pi_CU_Bigo2", cuBigo2)
				.addValue("pi_CU_SW_CODE", cuSwCode)
				.addValue("pi_CU_SW_NAME", cuSwName)
				.addValue("pi_CU_CUTYPE", cuCuType)
				.addValue("pi_GPS_X", gpsX)
				.addValue("pi_GPS_Y", gpsY)
				.addValue("pi_APP_User", appUser);

		return simpleJdbcCall.execute(inputParam);
	}
}
