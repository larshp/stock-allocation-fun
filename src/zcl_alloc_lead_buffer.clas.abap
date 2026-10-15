CLASS zcl_alloc_lead_buffer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS planned_lead
      IMPORTING
        iv_supplier_lead  TYPE i
        iv_buffer_percent TYPE i
      RETURNING
        VALUE(rv_lead)    TYPE i.

    METHODS buffer
      IMPORTING
        iv_supplier_lead  TYPE i
        iv_buffer_percent TYPE i
      RETURNING
        VALUE(rv_buffer)  TYPE i.

    METHODS is_safe
      IMPORTING
        iv_planned_lead TYPE i
        iv_actual_lead  TYPE i
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_lead_buffer IMPLEMENTATION.

  METHOD planned_lead.
    " The planned lead time carries the supplier lead time plus a buffer.
    IF iv_supplier_lead <= 0.
      RETURN.
    ENDIF.

    rv_lead = iv_supplier_lead * ( 100 + iv_buffer_percent ) DIV 100.
  ENDMETHOD.

  METHOD buffer.
    DATA lv_planned TYPE i.

    " The buffer is the planned lead time over the supplier lead time.
    lv_planned = planned_lead( iv_supplier_lead  = iv_supplier_lead
                               iv_buffer_percent = iv_buffer_percent ).
    rv_buffer = lv_planned - iv_supplier_lead.
  ENDMETHOD.

  METHOD is_safe.
    " The buffer is safe while the actual lead time stays within the plan.
    rv_ok = xsdbool( iv_actual_lead <= iv_planned_lead ).
  ENDMETHOD.

ENDCLASS.
