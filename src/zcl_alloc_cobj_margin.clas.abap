CLASS zcl_alloc_cobj_margin DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS margin
      IMPORTING
        iv_revenue       TYPE i
        iv_cost          TYPE i
      RETURNING
        VALUE(rv_margin) TYPE i.

    METHODS margin_percent
      IMPORTING
        iv_revenue        TYPE i
        iv_cost           TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_positive
      IMPORTING
        iv_margin    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_cobj_margin IMPLEMENTATION.

  METHOD margin.
    " The margin is what is left of the revenue once the cost is taken off.
    rv_margin = iv_revenue - iv_cost.
  ENDMETHOD.

  METHOD margin_percent.
    DATA lv_margin TYPE i.

    " The margin as a share of the revenue.
    IF iv_revenue = 0.
      RETURN.
    ENDIF.

    lv_margin = margin( iv_revenue = iv_revenue iv_cost = iv_cost ).
    rv_percent = lv_margin * 100 DIV iv_revenue.
  ENDMETHOD.

  METHOD is_positive.
    " A margin is positive once the object earns more than it costs.
    rv_ok = xsdbool( iv_margin > 0 ).
  ENDMETHOD.

ENDCLASS.
