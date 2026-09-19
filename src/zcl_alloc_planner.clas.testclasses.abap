CLASS ltcl_alloc_planner DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'PLANNER-01'.
    CONSTANTS c_bare  TYPE mard-matnr VALUE 'PLANNER-02'.
    CONSTANTS c_gone  TYPE mard-matnr VALUE 'PLANNER-03'.
    CONSTANTS c_here  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_there TYPE mard-werks VALUE '2000'.

    DATA mo_cut TYPE REF TO zcl_alloc_planner.

    METHODS setup.
    METHODS teardown.

    METHODS the_controller_is_found FOR TESTING RAISING cx_static_check.
    METHODS the_name_and_the_number FOR TESTING RAISING cx_static_check.
    METHODS another_plant_another_one FOR TESTING RAISING cx_static_check.
    METHODS no_controller_is_blank FOR TESTING RAISING cx_static_check.
    METHODS a_material_nobody_has FOR TESTING RAISING cx_static_check.
    METHODS a_code_with_no_name_stands FOR TESTING RAISING cx_static_check.
    METHODS the_answer_is_remembered FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_planner IMPLEMENTATION.

  METHOD setup.

    DATA lt_marc  TYPE STANDARD TABLE OF marc WITH EMPTY KEY.
    DATA lt_t024d TYPE STANDARD TABLE OF t024d WITH EMPTY KEY.

    mo_cut = NEW zcl_alloc_planner( ).

    lt_marc = VALUE #(
      mandt = sy-mandt
      ( matnr = c_matnr werks = c_here dispo = '101' )
      ( matnr = c_matnr werks = c_there dispo = '202' )
      ( matnr = c_bare werks = c_here dispo = '999' )
      ( matnr = c_gone werks = c_here ) ).

    INSERT marc FROM TABLE @lt_marc.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_t024d = VALUE #(
      mandt = sy-mandt
      ( werks = c_here dispo = '101' dsnam = 'Ada Cobb' dstel = '4471' )
      ( werks = c_there dispo = '202' dsnam = 'Bo Rees' dstel = '4472' ) ).

    INSERT t024d FROM TABLE @lt_t024d.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM marc WHERE matnr IN ( @c_matnr, @c_bare, @c_gone ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM t024d WHERE werks IN ( @c_here, @c_there ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD the_controller_is_found.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->looking_after( iv_matnr = c_matnr
                                   iv_werks = c_here )-dispo
      exp = '101' ).

  ENDMETHOD.

  METHOD the_name_and_the_number.

    " the number is the point of the column: a name without one is another
    " thing to go and look up
    DATA(ls_planner) = mo_cut->looking_after(
      iv_matnr = c_matnr
      iv_werks = c_here ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_planner-name
      exp = 'Ada Cobb' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_planner-phone
      exp = '4471' ).

  ENDMETHOD.

  METHOD another_plant_another_one.

    " who looks after a material is a plant by plant thing, and the whole
    " point of asking is that it is somebody else over there
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->looking_after( iv_matnr = c_matnr
                                   iv_werks = c_there )-name
      exp = 'Bo Rees' ).

  ENDMETHOD.

  METHOD no_controller_is_blank.

    DATA(ls_planner) = mo_cut->looking_after(
      iv_matnr = c_gone
      iv_werks = c_here ).

    cl_abap_unit_assert=>assert_initial( ls_planner ).

  ENDMETHOD.

  METHOD a_material_nobody_has.

    cl_abap_unit_assert=>assert_initial( mo_cut->looking_after(
      iv_matnr = 'PLANNER-NONE'
      iv_werks = c_here ) ).

  ENDMETHOD.

  METHOD a_code_with_no_name_stands.

    " a controller nobody put in the plant's list is still the answer to
    " "who looks after this": somebody who knows the code can find the person
    DATA(ls_planner) = mo_cut->looking_after(
      iv_matnr = c_bare
      iv_werks = c_here ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_planner-dispo
      exp = '999' ).
    cl_abap_unit_assert=>assert_initial( ls_planner-name ).

  ENDMETHOD.

  METHOD the_answer_is_remembered.

    " asked once, and then answered from memory: a page about forty short
    " materials in the same six plants asks about a handful of controllers
    mo_cut->looking_after(
      iv_matnr = c_matnr
      iv_werks = c_here ).

    DELETE FROM marc WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->looking_after( iv_matnr = c_matnr
                                   iv_werks = c_here )-name
      exp = 'Ada Cobb' ).

  ENDMETHOD.

ENDCLASS.
