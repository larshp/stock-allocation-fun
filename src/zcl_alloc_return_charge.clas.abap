CLASS zcl_alloc_return_charge DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             charge TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS charge
      IMPORTING
        iv_base          TYPE i
        iv_per_unit      TYPE i
        iv_quantity      TYPE i
      RETURNING
        VALUE(rv_charge) TYPE i.

    METHODS is_waived
      IMPORTING
        iv_reason_class TYPE string
        iv_value        TYPE i
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

    METHODS total
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rv_charge) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_charge IMPLEMENTATION.

  METHOD charge.
    " A return shipment pays a fixed handling charge plus a per-unit rate.
    IF iv_quantity <= 0 OR iv_base < 0 OR iv_per_unit < 0.
      RETURN.
    ENDIF.

    rv_charge = iv_base + iv_quantity * iv_per_unit.
  ENDMETHOD.

  METHOD is_waived.
    " The charge is waived when the return is the seller's fault (a quality or
    " logistics reason) or when the goods are valuable enough to cover it.
    IF iv_reason_class = 'QUALITY' OR iv_reason_class = 'LOGISTICS'.
      rv_ok = abap_true.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( iv_value >= 1000 ).
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-charge > 0.
        rv_charge = rv_charge + ls_line-charge.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
