package com.joatech.gasmax.webapi.domains;

import java.io.Serializable;

import lombok.Data;

@Data
public class CustomerMeterInfo implements Serializable {
	
	private static final long serialVersionUID = 4916626733855650085L;
	
	private String areaCode = "";
	private String cuCode = "";
	private String cuGumTerm = "";
	private String cuGumDate = "";
	private String cuBarCode = "";
	private String cuMeterNo = "";
	private String cuMeterCo = "";
	private String cuMeterLR = "";
	private String cuMeterType = "";
	private float cuMeterM3 = 0.0F;
	private String cuMeterDT = "";
	private String appUser = "";
}
