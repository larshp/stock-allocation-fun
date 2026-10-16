CLASS zcl_alloc_quota DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_source,
             supplier TYPE string,
             quota    TYPE i,
           END OF ty_source.
    TYPES ty_source_tt TYPE STANDARD TABLE OF ty_source WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_alloc,
             supplier TYPE string,
             quantity TYPE i,
           END OF ty_alloc.
    TYPES ty_alloc_tt TYPE STANDARD TABLE OF ty_alloc WITH DEFAULT KEY.

    METHODS split
      IMPORTING
        it_sources        TYPE ty_source_tt
        iv_total_quantity TYPE i
      RETURNING
        VALUE(rt_alloc)   TYPE ty_alloc_tt.

    METHODS share_of
      IMPORTING
        it_sources      TYPE ty_source_tt
        iv_supplier     TYPE string
      RETURNING
        VALUE(rv_share) TYPE i.

    METHODS total_quota
      IMPORTING
        it_sources      TYPE ty_source_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_quota IMPLEMENTATION.

  METHOD total_quota.
    LOOP AT it_sources INTO DATA(ls_source).
      IF ls_source-quota > 0.
        rv_total = rv_total + ls_source-quota.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD split.
    DATA lv_total TYPE i.
    DATA ls_alloc TYPE ty_alloc.

    lv_total = total_quota( it_sources ).
    IF lv_total <= 0 OR iv_total_quantity <= 0.
      RETURN.
    ENDIF.

    " Each source takes a share of the quantity in proportion to its quota.
    LOOP AT it_sources INTO DATA(ls_source).
      IF ls_source-quota <= 0.
        CONTINUE.
      ENDIF.

      ls_alloc-supplier = ls_source-supplier.
      ls_alloc-quantity = iv_total_quantity * ls_source-quota DIV lv_total.
      APPEND ls_alloc TO rt_alloc.
    ENDLOOP.
  ENDMETHOD.

  METHOD share_of.
    DATA lv_total TYPE i.
    DATA lv_quota TYPE i.

    lv_total = total_quota( it_sources ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_sources INTO DATA(ls_source).
      IF ls_source-supplier = iv_supplier.
        lv_quota = ls_source-quota.
        EXIT.
      ENDIF.
    ENDLOOP.

    rv_share = lv_quota * 100 DIV lv_total.
  ENDMETHOD.

ENDCLASS.
