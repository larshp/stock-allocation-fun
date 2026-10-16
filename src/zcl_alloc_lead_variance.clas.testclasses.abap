CLASS ltcl_alloc_lead_variance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lead_variance.
    DATA mt_val TYPE zcl_alloc_lead_variance=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS computes_variance FOR TESTING.
    METHODS computes_std_dev  FOR TESTING.
    METHODS reliable_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_lead_variance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lead_variance( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD computes_variance.
    add( 4 ).
    add( 6 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( mt_val ) exp = 1 ).
  ENDMETHOD.

  METHOD computes_std_dev.
    add( 4 ).
    add( 6 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->std_dev( mt_val ) exp = 1 ).
  ENDMETHOD.

  METHOD reliable_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_reliable( iv_std_dev = 1 iv_threshold = 2 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_reliable( iv_std_dev = 3 iv_threshold = 2 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
