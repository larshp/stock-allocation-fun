CLASS zcl_alloc_subst_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        is_result      TYPE zcl_alloc_subst_chain=>ty_result
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_subst_json IMPLEMENTATION.

  METHOD build.
    DATA lv_first TYPE abap_bool.

    rv_json = '{'.
    rv_json = rv_json && '"path":['.

    lv_first = abap_true.

    LOOP AT is_result-path INTO DATA(lv_matnr).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      rv_json = rv_json && |"{ lv_matnr }"|.
    ENDLOOP.

    rv_json = rv_json && '],'.
    rv_json = rv_json && |"final_matnr":"{ is_result-final_matnr }",|.
    rv_json = rv_json && |"steps":{ is_result-steps }|.
    rv_json = rv_json && '}'.
  ENDMETHOD.

ENDCLASS.
