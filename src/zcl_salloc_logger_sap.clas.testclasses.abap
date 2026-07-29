CLASS ltcl_logger_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS setup.
    METHODS writes_audit_row FOR TESTING RAISING zcx_salloc_integration.
ENDCLASS.
CLASS ltcl_logger_sap IMPLEMENTATION.
  METHOD setup.
    DELETE FROM zsalloc_log.
  ENDMETHOD.
  METHOD writes_audit_row.
    DATA(logger) = NEW zcl_salloc_logger_sap( ).
    logger->zif_salloc_logger~log(
      iv_event = 'ALLOCATE'
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_quantity = 5 ).
    SELECT SINGLE event, quantity FROM zsalloc_log INTO @DATA(saved).
    cl_abap_unit_assert=>assert_equals( act = saved-event exp = 'ALLOCATE' ).
    cl_abap_unit_assert=>assert_equals( act = saved-quantity exp = 5 ).
  ENDMETHOD.
ENDCLASS.
