package com.joatech.gasmax.webapi.services;

import java.util.Map;

import com.joatech.gasmax.webapi.domains.ConfigSet;

/*
 * 환경설정 저장(SP 환경저장)
 */
public interface IConfigSetService {
	
	Map<String, Object> updateConfigSet(ConfigSet configSet);

}
