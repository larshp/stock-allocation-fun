CLASS zcl_alloc_return_inspect DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             material TYPE matnr,
             result   TYPE string,
           END OF ty_result.
    TYPES ty_result_tt TYPE STANDARD TABLE OF ty_result WITH DEFAULT KEY.

    METHODS record
      IMPORTING
        is_result TYPE ty_result.

    METHODS result_of
      IMPORTING
        iv_material      TYPE matnr
      RETURNING
        VALUE(rv_result) TYPE string.

    METHODS missing
      IMPORTING
        it_expected       TYPE ty_result_tt
      RETURNING
        VALUE(rt_missing) TYPE ty_result_tt.

    METHODS clear.

  PRIVATE SECTION.
    DATA mt_results TYPE ty_result_tt.

ENDCLASS.


CLASS zcl_alloc_return_inspect IMPLEMENTATION.

  METHOD record.
    APPEND is_result TO mt_results.
  ENDMETHOD.

  METHOD result_of.
    " A later record wins, so the inspection can be corrected without clearing it.
    LOOP AT mt_results INTO DATA(ls_result).
      IF ls_result-material = iv_material.
        rv_result = ls_result-result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD missing.
    DATA lv_result TYPE string.

    LOOP AT it_expected INTO DATA(ls_expected).
      lv_result = result_of( ls_expected-material ).

      IF lv_result IS INITIAL.
        APPEND ls_expected TO rt_missing.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD clear.
    CLEAR mt_results.
  ENDMETHOD.

ENDCLASS.
