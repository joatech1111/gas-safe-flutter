package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

import com.joatech.gasmax.webapi.domains.CustomerMeterInfo;
import com.joatech.gasmax.webapi.domains.MeterCheckStatusInfo;
import com.joatech.gasmax.webapi.domains.MeterCustomer;
import com.joatech.gasmax.webapi.domains.SaveMeterValue;

/*
 * 검침 거래처 검색(FN_검침 거래처 검색)
 */
public interface IMeterCustomerService {
	
	//List<Map<String, Object>> getAllSearchMeterCustomerListBy(String areaCode);
	
	List<Map<String, Object>> getAllSearchMeterCustomerListBy(MeterCustomer meterCustomer);
	List<Map<String, Object>> getSNoSearchMeterCustomerListBy(MeterCustomer meterCustomer);
	List<Map<String, Object>> getTurmSearchMeterCustomerListBy(MeterCustomer meterCustomer);
	List<Map<String, Object>> getGpsSearchMeterCustomerListBy(MeterCustomer meterCustomer);
	List<Map<String, Object>> getMeterCheckStatusListBy(MeterCheckStatusInfo meterCheckStatusInfo);
	List<Map<String, Object>> getGpsMeterCheckStatusListBy(MeterCheckStatusInfo meterCheckStatusInfo);

	Map<String, Object> addNewSaveMeterValue(SaveMeterValue saveMeterValue);
	Map<String, Object> updateSaveMeterValue(SaveMeterValue saveMeterValue);
	Map<String, Object> deleteSaveMeterValue(SaveMeterValue saveMeterValue);

	Map<String, Object> updateCustomerMeterInfo(CustomerMeterInfo customerMeterInfo);
}
