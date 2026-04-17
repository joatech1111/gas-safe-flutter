package com.joatech.gasmax.webapi.services;

import java.util.Optional;

import com.joatech.gasmax.webapi.domains.AnSobiSign;

/*
 * 사인 처리
 */
public interface IAnSobiSignService {
	Optional<AnSobiSign> getAnSobiSignByAreaCodeAndAnzCuCodeAndAnzSno(String areaCode, String anzCuCode, String anzSno);
	String getSignByAreaCodeAndAnzCuCodeAndAnzSno(String areaCode, String anzCuCode, String anzSno);
	int getCountByAreaCodeAndAnzCuCodeAndAnzSno(String areaCode, String anzCuCode, String anzSno);

	int saveAnSobiSign(AnSobiSign anSobiSign);
	int deleteAnSobiSign(AnSobiSign anSobiSign);
}
