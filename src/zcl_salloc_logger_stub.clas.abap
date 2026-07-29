CLASS zcl_salloc_logger_stub DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salloc_logger.
    TYPES:
      BEGIN OF ty_entry,
        event TYPE zif_salloc_types=>ty_log_event,
        order_id TYPE zif_salloc_types=>ty_order_id,
        quantity TYPE zif_salloc_types=>ty_quantity,
      END OF ty_entry.
    TYPES tt_entries TYPE STANDARD TABLE OF ty_entry WITH EMPTY KEY.
    METHODS constructor IMPORTING iv_fail TYPE abap_bool DEFAULT abap_false.
    METHODS get_count RETURNING VALUE(rv_count) TYPE i.
    METHODS get_entries RETURNING VALUE(rt_entries) TYPE tt_entries.
  PRIVATE SECTION.
    DATA mv_count TYPE i.
    DATA mv_fail TYPE abap_bool.
    DATA mt_entries TYPE tt_entries.
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
    APPEND VALUE #(
      event = iv_event
      order_id = iv_order_id
      quantity = iv_quantity ) TO mt_entries.
  ENDMETHOD.
  METHOD get_count.
    rv_count = mv_count.
  ENDMETHOD.
  METHOD get_entries.
    rt_entries = mt_entries.
  ENDMETHOD.
ENDCLASS.
