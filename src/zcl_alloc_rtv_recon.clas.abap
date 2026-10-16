CLASS zcl_alloc_rtv_recon DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS reconcile
      IMPORTING
        iv_expected    TYPE i
        iv_actual      TYPE i
      RETURNING
        VALUE(rv_diff) TYPE i.

    METHODS difference
      IMPORTING
        iv_expected    TYPE i
        iv_actual      TYPE i
      RETURNING
        VALUE(rv_diff) TYPE i.

    METHODS is_settled
      IMPORTING
        iv_expected  TYPE i
        iv_actual    TYPE i
        iv_tolerance TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_rtv_recon IMPLEMENTATION.

  METHOD reconcile.
    " A positive result means the vendor credited more than expected.
    rv_diff = iv_actual - iv_expected.
  ENDMETHOD.

  METHOD difference.
    DATA lv_diff TYPE i.

    lv_diff = reconcile( iv_expected = iv_expected
                         iv_actual   = iv_actual ).

    " The absolute deviation is measured without the ABS built-in.
    IF lv_diff < 0.
      rv_diff = 0 - lv_diff.
    ELSE.
      rv_diff = lv_diff.
    ENDIF.
  ENDMETHOD.

  METHOD is_settled.
    " The claim settles when the credit is within the tolerance.
    IF iv_tolerance < 0.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( difference( iv_expected = iv_expected
                                 iv_actual   = iv_actual ) <= iv_tolerance ).
  ENDMETHOD.

ENDCLASS.
