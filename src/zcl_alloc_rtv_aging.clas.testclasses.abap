CLASS ltcl_alloc_rtv_aging DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rtv_aging.
    DATA mt_age TYPE zcl_alloc_rtv_aging=>ty_ages_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_age TYPE i.

    METHODS buckets_days  FOR TESTING.
    METHODS oldest        FOR TESTING.
    METHODS overdue_count FOR TESTING.
    METHODS empty_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rtv_aging IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rtv_aging( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_age TO mt_age.
  ENDMETHOD.

  METHOD buckets_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 10 ) exp = '0-30' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 100 ) exp = '90+' ).
  ENDMETHOD.

  METHOD oldest.
    add( 10 ).
    add( 40 ).
    add( 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->oldest_days( mt_age ) exp = 100 ).
  ENDMETHOD.

  METHOD overdue_count.
    add( 10 ).
    add( 40 ).
    add( 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overdue( it_ages = mt_age iv_limit = 60 )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overdue( it_ages = mt_age iv_limit = 90 )
      exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->oldest_days( mt_age ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overdue( it_ages = mt_age iv_limit = 60 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
