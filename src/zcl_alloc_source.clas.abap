CLASS zcl_alloc_source DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_source,
             supplier TYPE string,
             quota    TYPE i,
             fixed    TYPE abap_bool,
           END OF ty_source.
    TYPES ty_source_tt TYPE STANDARD TABLE OF ty_source WITH DEFAULT KEY.

    METHODS select
      IMPORTING
        it_sources         TYPE ty_source_tt
      RETURNING
        VALUE(rv_supplier) TYPE string.

    METHODS is_quota
      IMPORTING
        it_sources   TYPE ty_source_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS quota_of
      IMPORTING
        it_sources      TYPE ty_source_tt
        iv_supplier     TYPE string
      RETURNING
        VALUE(rv_quota) TYPE i.

ENDCLASS.


CLASS zcl_alloc_source IMPLEMENTATION.

  METHOD select.
    DATA lv_best   TYPE i.
    DATA lv_found  TYPE abap_bool.

    " A fixed source always wins; otherwise the highest quota does.
    LOOP AT it_sources INTO DATA(ls_source).
      IF ls_source-fixed = abap_true.
        rv_supplier = ls_source-supplier.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT it_sources INTO ls_source.
      IF lv_found = abap_false OR ls_source-quota > lv_best.
        lv_found = abap_true.
        lv_best = ls_source-quota.
        rv_supplier = ls_source-supplier.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_quota.
    DATA lv_count TYPE i.

    " A quota arrangement is in play once more than one source carries quota.
    LOOP AT it_sources INTO DATA(ls_source).
      IF ls_source-quota > 0.
        lv_count = lv_count + 1.
      ENDIF.
    ENDLOOP.

    rv_ok = xsdbool( lv_count > 1 ).
  ENDMETHOD.

  METHOD quota_of.
    LOOP AT it_sources INTO DATA(ls_source).
      IF ls_source-supplier = iv_supplier.
        rv_quota = ls_source-quota.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
