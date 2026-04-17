package com.joatech.gasmax.webapi.exceptions;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import com.fasterxml.jackson.core.JsonParseException;
import com.joatech.gasmax.webapi.defines.GasMaxErrors;
import com.joatech.gasmax.webapi.domains.RestAPIResult;

@ControllerAdvice
@Controller
public class GasMaxApiResponseEntityExceptionHandler extends ResponseEntityExceptionHandler {

	@ExceptionHandler(Exception.class)
	public final ResponseEntity<RestAPIResult> handleAllExceptions(Exception ex, WebRequest request) {

		ErrorDetails errorDetails = new ErrorDetails(ex.getMessage(), request.getDescription(false).toString());
		RestAPIResult errorResult = new RestAPIResult(	GasMaxErrors.ERROR_FAIL, 
														GasMaxErrors.ERROR_CODE_UNSPECIFIED, 
														errorDetails);
		return new ResponseEntity<>(errorResult, HttpStatus.INTERNAL_SERVER_ERROR);
	}

    @ExceptionHandler(JsonParseException.class)
    public ResponseEntity<RestAPIResult> handleJsonParseException(Exception ex, WebRequest request) {

		ErrorDetails errorDetails = new ErrorDetails(ex.getMessage(), request.getDescription(false).toString());
		RestAPIResult errorResult = new RestAPIResult(	GasMaxErrors.ERROR_INVALID_JSON_FORMAT, 
														GasMaxErrors.ERROR_CODE_INVALID_JSON_FORMAT, 
														errorDetails);
		ResponseEntity<RestAPIResult> responseEntity = new ResponseEntity<>(errorResult, HttpStatus.FORBIDDEN);
        return responseEntity;
	}

    @ExceptionHandler(JsonNodeNotFoundException.class)
    public ResponseEntity<RestAPIResult> handleJsonNodeNotFoundException(Exception ex, WebRequest request) {

		ErrorDetails errorDetails = new ErrorDetails(  GasMaxErrors.ERROR_JSON_NODE_NOT_FOUND + " : " + ex.getMessage(), request.getDescription(false).toString());
		RestAPIResult errorResult = new RestAPIResult(	GasMaxErrors.ERROR_JSON_NODE_NOT_FOUND, 
														GasMaxErrors.ERROR_CODE_JSON_NODE_NOT_FOUND, 
														errorDetails);
		ResponseEntity<RestAPIResult> responseEntity = new ResponseEntity<>(errorResult, HttpStatus.FORBIDDEN);
        return responseEntity;
	}


    @ExceptionHandler(LoginFailException.class)
    public ResponseEntity<RestAPIResult> handleLoginFail(Exception ex, WebRequest request) {

		ErrorDetails errorDetails = new ErrorDetails(ex.getMessage(), request.getDescription(false).toString());
		RestAPIResult errorResult = new RestAPIResult(	GasMaxErrors.ERROR_LOGIN_FAILED, 
														GasMaxErrors.ERROR_CODE_LOGIN_FAILED, 
														errorDetails);
		ResponseEntity<RestAPIResult> responseEntity = new ResponseEntity<>(errorResult, HttpStatus.FORBIDDEN);
        return responseEntity;
	}
    
    @ExceptionHandler(InvalidSessionIdException.class)
    public ResponseEntity<RestAPIResult> handleInvalidSessionId(Exception ex, WebRequest request) {

		ErrorDetails errorDetails = new ErrorDetails(ex.getMessage(), request.getDescription(false).toString());
		RestAPIResult errorResult = new RestAPIResult(	GasMaxErrors.ERROR_SESSION_ID_IS_INVALID, 
														GasMaxErrors.ERROR_CODE_SESSION_ID_IS_INVALID, 
														errorDetails);
		ResponseEntity<RestAPIResult> responseEntity = new ResponseEntity<>(errorResult, HttpStatus.FORBIDDEN);
        return responseEntity;
	}
    
    @ExceptionHandler(SessionIdNotReceivedException.class)
    public ResponseEntity<RestAPIResult> handleSessionIdNotReceived(Exception ex, WebRequest request) {

		ErrorDetails errorDetails = new ErrorDetails(ex.getMessage(), request.getDescription(false).toString());
		RestAPIResult errorResult = new RestAPIResult(	GasMaxErrors.ERROR_SESSION_ID_NOT_RECEIVED, 
														GasMaxErrors.ERROR_CODE_SESSION_ID_NOT_RECEIVED,
														errorDetails);
		ResponseEntity<RestAPIResult> responseEntity = new ResponseEntity<>(errorResult, HttpStatus.FORBIDDEN);
        return responseEntity;
	}
    

}
