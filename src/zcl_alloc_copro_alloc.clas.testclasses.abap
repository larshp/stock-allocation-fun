CLASS ltcl_alloc_copro_alloc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_copro_alloc.
    DATA mt_weight TYPE zcl_alloc_copro_alloc=>ty_weight_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_product TYPE string
        iv_weight  TYPE i.

    METHODS allocates_cost FOR TESTING.
    METHODS sums_joint     FOR TESTING.
    METHODS allocated_rule FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_copro_alloc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_copro_alloc( ).

    add( iv_product = 'P1' iv_weight = 1 ).
    add( iv_product = 'P2' iv_weight = 3 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_weight TYPE zcl_alloc_copro_alloc=>ty_weight.

    ls_weight-product = iv_product.
    ls_weight-weight = iv_weight.
    APPEND ls_weight TO mt_weight.
  ENDMETHOD.

  METHOD allocates_cost.
    DATA lt_share TYPE zcl_alloc_copro_alloc=>ty_share_tt.

    lt_share = mo_cut->allocate( iv_joint_total = 400 it_weights = mt_weight ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_share ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_share[ 1 ]-amount exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_share[ 2 ]-amount exp = 300 ).
  ENDMETHOD.

  METHOD sums_joint.
    DATA lt_share TYPE zcl_alloc_copro_alloc=>ty_share_tt.

    lt_share = mo_cut->allocate( iv_joint_total = 400 it_weights = mt_weight ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->joint_total( lt_share ) exp = 400 ).
  ENDMETHOD.

  METHOD allocated_rule.
    DATA lt_share TYPE zcl_alloc_copro_alloc=>ty_share_tt.

    lt_share = mo_cut->allocate( iv_joint_total = 400 it_weights = mt_weight ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_allocated( lt_share ) exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
