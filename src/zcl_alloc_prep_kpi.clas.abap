CLASS zcl_alloc_prep_kpi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS value_of
      IMPORTING
        iv_actual         TYPE i
        iv_target         TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_on_target
      IMPORTING
        iv_actual    TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS gap
      IMPORTING
        iv_actual     TYPE i
        iv_target     TYPE i
      RETURNING
        VALUE(rv_gap) TYPE i.

ENDCLASS.


CLASS zcl_alloc_prep_kpi IMPLEMENTATION.

  METHOD value_of.
    " The KPI is the actual as a percentage of the target.
    IF iv_target = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_actual * 100 DIV iv_target.
  ENDMETHOD.

  METHOD is_on_target.
    " The KPI is on target once the actual reaches it.
    rv_ok = xsdbool( iv_actual >= iv_target ).
  ENDMETHOD.

  METHOD gap.
    " The gap is the shortfall against the target.
    IF iv_actual >= iv_target.
      RETURN.
    ENDIF.

    rv_gap = iv_target - iv_actual.
  ENDMETHOD.

ENDCLASS.
