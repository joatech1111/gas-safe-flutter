package com.joatech.gasmax.webapi.exceptions;

import java.io.Serializable;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/*************************************************
* GasMaxApiException
*
* @author Heecheol Jeong
* 
*************************************************/

@ResponseStatus(HttpStatus.OK)
public class GasMaxApiException extends RuntimeException implements Serializable {

	private static final long serialVersionUID = -5852128654854185447L;

	/*************************************************
	* LOGGER Variable
	*************************************************/
	private static final Logger LOGGER = LoggerFactory.getLogger(GasMaxApiException.class);		

	/*************************************************
	* GasMaxApiException constructor
	*************************************************/
	public GasMaxApiException(final String exception) {
		super(exception);
		LOGGER.error(this.getLocalizedMessage());
	}
}
