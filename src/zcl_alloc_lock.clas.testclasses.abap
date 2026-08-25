CLASS ltcl_alloc_lock DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS setup.
    METHODS acquire_release FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_lock IMPLEMENTATION.


  METHOD setup.
    zcl_alloc_lock=>release( ).
  ENDMETHOD.


  METHOD acquire_release.
    " first acquire succeeds, second fails until released
    DATA(lv_first) = zcl_alloc_lock=>acquire( ).
    cl_abap_unit_assert=>assert_true( lv_first ).

    DATA(lv_second) = zcl_alloc_lock=>acquire( ).
    cl_abap_unit_assert=>assert_false( lv_second ).

    cl_abap_unit_assert=>assert_true( zcl_alloc_lock=>is_locked( ) ).

    zcl_alloc_lock=>release( ).
    cl_abap_unit_assert=>assert_false( zcl_alloc_lock=>is_locked( ) ).

    " after release acquiring works again
    DATA(lv_third) = zcl_alloc_lock=>acquire( ).
    cl_abap_unit_assert=>assert_true( lv_third ).
  ENDMETHOD.


ENDCLASS.
