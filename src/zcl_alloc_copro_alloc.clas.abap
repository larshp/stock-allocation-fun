CLASS zcl_alloc_copro_alloc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_weight,
             product TYPE string,
             weight  TYPE i,
           END OF ty_weight.
    TYPES ty_weight_tt TYPE STANDARD TABLE OF ty_weight WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_share,
             product TYPE string,
             amount  TYPE i,
           END OF ty_share.
    TYPES ty_share_tt TYPE STANDARD TABLE OF ty_share WITH DEFAULT KEY.

    METHODS allocate
      IMPORTING
        iv_joint_total   TYPE i
        it_weights       TYPE ty_weight_tt
      RETURNING
        VALUE(rt_shares) TYPE ty_share_tt.

    METHODS joint_total
      IMPORTING
        it_shares       TYPE ty_share_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS is_allocated
      IMPORTING
        it_shares    TYPE ty_share_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_copro_alloc IMPLEMENTATION.

  METHOD allocate.
    DATA lv_total_weight TYPE i.
    DATA ls_share TYPE ty_share.

    " The joint cost is shared out over the products at their weight.
    LOOP AT it_weights INTO DATA(ls_weight).
      lv_total_weight = lv_total_weight + ls_weight-weight.
    ENDLOOP.

    IF lv_total_weight <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_weights INTO DATA(ls_line).
      CLEAR ls_share.
      ls_share-product = ls_line-product.
      ls_share-amount = iv_joint_total * ls_line-weight DIV lv_total_weight.
      APPEND ls_share TO rt_shares.
    ENDLOOP.

    SORT rt_shares BY product ASCENDING.
  ENDMETHOD.

  METHOD joint_total.
    " The joint total of the allocated shares.
    LOOP AT it_shares INTO DATA(ls_share).
      rv_total = rv_total + ls_share-amount.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_allocated.
    " The cost is allocated once the shares carry a total.
    rv_ok = xsdbool( joint_total( it_shares ) > 0 ).
  ENDMETHOD.

ENDCLASS.
