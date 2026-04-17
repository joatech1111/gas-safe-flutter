package com.joatech.gasmax.webapi.services;

import java.util.Map;
import com.joatech.gasmax.webapi.domains.CustomerInfo;

/*
 * 거래처 검색/정보
 */
public interface ICustomerInfoService {
	
	/*
	 * List<Map<String, Object>> updateCustomerInfoServiceBy(String div, String
	 * areaCode, String cuCode, String cuType, String cuName, String cuUserName,
	 * String cuTel, String cuTelFind, String cuHp, String cuHpFind, String
	 * zipCode,String cuAddr1, String cuAddr2, String cuBigo1, String cuBigo2,
	 * String cuSwCode, String cuSwName, String cuCuType, String gpsX, String gpsY,
	 * String appUser);
	 */
	
	//List<Map<String, Object>> updateCustomerInfoServiceBy(CustomerInfo customerInfo);
	
	Map<String, Object> updateCustomerInfoService(CustomerInfo customerInfo);

}
