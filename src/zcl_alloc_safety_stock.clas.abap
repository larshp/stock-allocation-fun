CLASS zcl_alloc_safety_stock DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS stock
      IMPORTING
        iv_service_factor TYPE i
        iv_lead_days      TYPE i
        iv_demand_std_dev TYPE i
      RETURNING
        VALUE(rv_stock)   TYPE i.

    METHODS is_valid
      IMPORTING
        iv_stock     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS recommended
      IMPORTING
        iv_current_stock  TYPE i
        iv_required_stock TYPE i
      RETURNING
        VALUE(rv_add)     TYPE i.

  PRIVATE SECTION.
    METHODS square_root
      IMPORTING
        iv_value       TYPE i
      RETURNING
        VALUE(rv_root) TYPE i.

ENDCLASS.


CLASS zcl_alloc_safety_stock IMPLEMENTATION.

  METHOD square_root.
    DATA lv_limit TYPE i.

    lv_limit = iv_value.
    IF lv_limit < 0.
      lv_limit = 0.
    ENDIF.

    WHILE ( rv_root + 1 ) * ( rv_root + 1 ) <= lv_limit.
      rv_root = rv_root + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD stock.
    DATA lv_root TYPE i.

    " The safety stock rises with the service factor and the demand spread, and
    " only with the root of the lead time.
    IF iv_service_factor <= 0 OR iv_lead_days <= 0 OR iv_demand_std_dev <= 0.
      RETURN.
    ENDIF.

    lv_root = square_root( iv_lead_days ).
    rv_stock = iv_service_factor * iv_demand_std_dev * lv_root DIV 100.
  ENDMETHOD.

  METHOD is_valid.
    rv_ok = xsdbool( iv_stock > 0 ).
  ENDMETHOD.

  METHOD recommended.
    " The recommendation only ever adds stock up to the required level.
    IF iv_current_stock >= iv_required_stock.
      RETURN.
    ENDIF.

    rv_add = iv_required_stock - iv_current_stock.
  ENDMETHOD.

ENDCLASS.
