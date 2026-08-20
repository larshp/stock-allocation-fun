CLASS ltcl_alloc_owned_by DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '9501'.
    CONSTANTS c_mine  TYPE mard-matnr VALUE 'OWNED-MAT-01'.
    CONSTANTS c_yours TYPE mard-matnr VALUE 'OWNED-MAT-02'.
    CONSTANTS c_gone  TYPE mard-matnr VALUE 'OWNED-MAT-03'.

    METHODS setup.
    METHODS teardown.

    METHODS one_controller_is_read FOR TESTING.
    METHODS no_controller_is_no_answer FOR TESTING.
    METHODS a_deleted_material_is_out FOR TESTING.
    METHODS no_controller_owns_everything FOR TESTING.
    METHODS a_material_of_another_is_out FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_owned_by IMPLEMENTATION.

  METHOD setup.

    DATA lt_marc TYPE STANDARD TABLE OF marc WITH EMPTY KEY.

    lt_marc = VALUE #(
      ( mandt = sy-mandt matnr = c_mine werks = c_werks dispo = '001' )
      ( mandt = sy-mandt matnr = c_yours werks = c_werks dispo = '002' )
      ( mandt = sy-mandt matnr = c_gone werks = c_werks dispo = '001'
        lvorm = 'X' ) ).

    INSERT marc FROM TABLE @lt_marc.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'plant master fixture could not be inserted' ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM marc WHERE matnr IN ( @c_mine, @c_yours, @c_gone ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD one_controller_is_read.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_alloc_owned_by=>materials(
        iv_werks = c_werks
        it_dispo = VALUE #( ( '001' ) ) )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( c_mine ) )
      msg = 'a planner asking for their own materials gets their own' ).

  ENDMETHOD.

  METHOD no_controller_is_no_answer.

    cl_abap_unit_assert=>assert_initial(
      act = zcl_alloc_owned_by=>materials(
        iv_werks = c_werks
        it_dispo = VALUE #( ) )
      msg = 'nobody asked about a controller, so nothing was looked up' ).

  ENDMETHOD.

  METHOD a_deleted_material_is_out.

    DATA(lt_matnr) = zcl_alloc_owned_by=>materials(
      iv_werks = c_werks
      it_dispo = VALUE #( ( '001' ) ) ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_gone ] ) )
      msg = 'a material on its way out of the plant is nobody morning work' ).

  ENDMETHOD.

  METHOD no_controller_owns_everything.

    cl_abap_unit_assert=>assert_true(
      act = zcl_alloc_owned_by=>is_owned(
        iv_matnr = c_yours
        it_owned = VALUE #( ( c_mine ) )
        it_dispo = VALUE #( ) )
      msg = 'an empty list of controllers is no restriction, as everywhere else' ).

  ENDMETHOD.

  METHOD a_material_of_another_is_out.

    cl_abap_unit_assert=>assert_false(
      act = zcl_alloc_owned_by=>is_owned(
        iv_matnr = c_yours
        it_owned = VALUE #( ( c_mine ) )
        it_dispo = VALUE #( ( '001' ) ) )
      msg = 'and a controller who was named owns what the master data says' ).

  ENDMETHOD.

ENDCLASS.
