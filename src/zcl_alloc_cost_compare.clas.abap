CLASS zcl_alloc_cost_compare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS cheaper
      IMPORTING
        iv_cost_a    TYPE i
        iv_cost_b    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS difference
      IMPORTING
        iv_cost_a      TYPE i
        iv_cost_b      TYPE i
      RETURNING
        VALUE(rv_diff) TYPE i.

    METHODS best_option
      IMPORTING
        iv_cost_a        TYPE i
        iv_cost_b        TYPE i
      RETURNING
        VALUE(rv_option) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cost_compare IMPLEMENTATION.

  METHOD cheaper.
    " The first option is cheaper while its cost sits below the second.
    rv_ok = xsdbool( iv_cost_a < iv_cost_b ).
  ENDMETHOD.

  METHOD difference.
    DATA lv_diff TYPE i.

    " The gap between the two costs is measured without the ABS built-in.
    lv_diff = iv_cost_a - iv_cost_b.
    IF lv_diff < 0.
      rv_diff = 0 - lv_diff.
    ELSE.
      rv_diff = lv_diff.
    ENDIF.
  ENDMETHOD.

  METHOD best_option.
    " The cheaper option wins; on a tie the first is kept.
    IF iv_cost_a <= iv_cost_b.
      rv_option = 1.
    ELSE.
      rv_option = 2.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
