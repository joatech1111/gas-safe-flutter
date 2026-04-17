package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

/*
 * 검침현환(FN 검침현황)
 */
public interface IMeterInsertService {
	
	List<Map<String, Object>> getAllMeterInsertServiceBy(String areaCode, String findStr, String gumDateF, String gumDateT, String cuCode, String aptCd, String swCd, String manCd, 
														 String jyCd, String addrText, String smartMeterYn, String gpsX, String gpsY);
	
	List<Map<String, Object>> getGpsMeterInsertServiceBy(String areaCode, String findStr, String gumDateF, String gumDateT, String cuCode, String aptCd, String swCd, String manCd, 
			 						     				 String jyCd, String addrText, String smartMeterYn, String gpsX, String gpsY);

}
