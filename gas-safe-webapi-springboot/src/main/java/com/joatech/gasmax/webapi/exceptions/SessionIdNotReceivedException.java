package com.joatech.gasmax.webapi.exceptions;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.FORBIDDEN)
public class SessionIdNotReceivedException extends RuntimeException {

	private static final long serialVersionUID = -1494869604178700866L;
	private final Logger logger = LoggerFactory.getLogger(getClass());

	public SessionIdNotReceivedException(String exception) {
		super(exception);
		logger.error(this.getLocalizedMessage());
	}
}
