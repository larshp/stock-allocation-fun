CLASS zcl_salloc_logger_stub DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salloc_logger.
    METHODS constructor IMPORTING iv_fail TYPE abap_bool DEFAULT abap_false.
    METHODS get_count RETURNING VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mv_count TYPE i.
    DATA mv_fail TYPE abap_bool.
ENDCLASS.
CLASS zcl_salloc_logger_stub IMPLEMENTATION.
  METHOD constructor.
    mv_fail = iv_fail.
  ENDMETHOD.
  METHOD zif_salloc_logger~log.
    IF mv_fail = abap_true.
      RAISE EXCEPTION TYPE zcx_salloc_integration
        EXPORTING iv_operation = `LOG` iv_reason = `Configured logging failure`.
    ENDIF.
    mv_count = mv_count + 1.
  ENDMETHOD.
  METHOD get_count.
    rv_count = mv_count.
  ENDMETHOD.
ENDCLASS.
