CLASS zcl_alloc_rtv_claim DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS claim
      IMPORTING
        iv_quantity     TYPE i
        iv_unit_cost    TYPE i
      RETURNING
        VALUE(rv_claim) TYPE i.

    METHODS value
      IMPORTING
        iv_claim            TYPE i
        iv_approved_percent TYPE i
      RETURNING
        VALUE(rv_value)     TYPE i.

    METHODS is_valid
      IMPORTING
        iv_claim     TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_rtv_claim IMPLEMENTATION.

  METHOD claim.
    " The claim is the cost of what goes back to the vendor.
    IF iv_quantity <= 0 OR iv_unit_cost <= 0.
      RETURN.
    ENDIF.

    rv_claim = iv_quantity * iv_unit_cost.
  ENDMETHOD.

  METHOD value.
    " The vendor may approve only a share of the claim.
    IF iv_claim <= 0 OR iv_approved_percent <= 0.
      RETURN.
    ENDIF.

    rv_value = iv_claim * iv_approved_percent DIV 100.
  ENDMETHOD.

  METHOD is_valid.
    " A claim must be worth something and stay within the vendor's limit.
    rv_ok = xsdbool( iv_claim > 0 AND iv_limit > 0 AND iv_claim <= iv_limit ).
  ENDMETHOD.

ENDCLASS.
