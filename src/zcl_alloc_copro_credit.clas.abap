CLASS zcl_alloc_copro_credit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS credit
      IMPORTING
        iv_joint_cost     TYPE i
        iv_by_product_val TYPE i
      RETURNING
        VALUE(rv_credit)  TYPE i.

    METHODS is_credited
      IMPORTING
        iv_credit    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS net_cost
      IMPORTING
        iv_joint_cost TYPE i
        iv_credit     TYPE i
      RETURNING
        VALUE(rv_net) TYPE i.

ENDCLASS.


CLASS zcl_alloc_copro_credit IMPLEMENTATION.

  METHOD credit.
    " A by-product credits the joint cost with its own value.
    IF iv_by_product_val >= iv_joint_cost.
      RETURN.
    ENDIF.

    rv_credit = iv_joint_cost - iv_by_product_val.
  ENDMETHOD.

  METHOD is_credited.
    " The joint cost is credited once a by-product carries value.
    rv_ok = xsdbool( iv_credit > 0 ).
  ENDMETHOD.

  METHOD net_cost.
    " The net cost is what is left of the joint cost after the credit.
    IF iv_credit >= iv_joint_cost.
      RETURN.
    ENDIF.

    rv_net = iv_joint_cost - iv_credit.
  ENDMETHOD.

ENDCLASS.
