CLASS ltcl_other_plants DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'OTHERS-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'OTHERS-02'.
    CONSTANTS c_gone  TYPE mard-matnr VALUE 'OTHERS-03'.
    CONSTANTS c_here  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_there TYPE mard-werks VALUE '2000'.
    CONSTANTS c_far   TYPE mard-werks VALUE '3000'.

    DATA mo_cut TYPE REF TO zcl_alloc_other_plants.

    METHODS setup.
    METHODS teardown.

    METHODS the_other_plants_come_back FOR TESTING RAISING cx_static_check.
    METHODS the_asking_plant_is_left_out FOR TESTING RAISING cx_static_check.
    METHODS a_deleted_one_is_left_out FOR TESTING RAISING cx_static_check.
    METHODS another_material_is_its_own FOR TESTING RAISING cx_static_check.
    METHODS a_material_nobody_has FOR TESTING RAISING cx_static_check.
    METHODS the_answer_is_remembered FOR TESTING RAISING cx_static_check.
    METHODS preloading_answers_the_same FOR TESTING RAISING cx_static_check.
    METHODS preloading_reads_once FOR TESTING RAISING cx_static_check.
    METHODS one_object_serves_two_plants FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_other_plants IMPLEMENTATION.

  METHOD setup.

    DATA lt_marc TYPE STANDARD TABLE OF marc WITH EMPTY KEY.

    mo_cut = NEW zcl_alloc_other_plants( ).

    " the first material is in all three plants and flagged for deletion in
    " the last, the second is in one of them
    lt_marc = VALUE #(
      mandt = sy-mandt
      ( matnr = c_matnr werks = c_here )
      ( matnr = c_matnr werks = c_there )
      ( matnr = c_matnr werks = c_far lvorm = 'X' )
      ( matnr = c_other werks = c_far ) ).

    INSERT marc FROM TABLE @lt_marc.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM marc WHERE matnr IN ( @c_matnr, @c_other, @c_gone ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD the_other_plants_come_back.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->others( iv_matnr = c_matnr
                            iv_werks = c_here )
      exp = VALUE zcl_alloc_other_plants=>ty_werks_tab( ( c_there ) ) ).

  ENDMETHOD.

  METHOD the_asking_plant_is_left_out.

    DATA(lt_werks) = mo_cut->others(
      iv_matnr = c_matnr
      iv_werks = c_here ).

    cl_abap_unit_assert=>assert_false(
      act = line_exists( lt_werks[ table_line = c_here ] )
      msg = 'the plant that is short is not somewhere else to look' ).

  ENDMETHOD.

  METHOD a_deleted_one_is_left_out.

    " a material on its way out of a plant is not somewhere to move goods to
    " or from, which is what feature 76 decided for the run itself
    DATA(lt_werks) = mo_cut->others(
      iv_matnr = c_matnr
      iv_werks = c_here ).

    cl_abap_unit_assert=>assert_false( line_exists( lt_werks[ table_line = c_far ] ) ).

  ENDMETHOD.

  METHOD another_material_is_its_own.

    " the answers share one table, so the risk this guards against is one
    " material's plants turning up under another's
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->others( iv_matnr = c_other
                            iv_werks = c_here )
      exp = VALUE zcl_alloc_other_plants=>ty_werks_tab( ( c_far ) ) ).

  ENDMETHOD.

  METHOD a_material_nobody_has.

    cl_abap_unit_assert=>assert_initial( mo_cut->others(
      iv_matnr = c_gone
      iv_werks = c_here ) ).

  ENDMETHOD.

  METHOD the_answer_is_remembered.

    mo_cut->others(
      iv_matnr = c_matnr
      iv_werks = c_here ).

    DELETE FROM marc WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->others( iv_matnr = c_matnr
                            iv_werks = c_here )
      exp = VALUE zcl_alloc_other_plants=>ty_werks_tab( ( c_there ) ) ).

  ENDMETHOD.

  METHOD preloading_answers_the_same.

    mo_cut->preload( VALUE #( ( c_matnr ) ( c_other ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->others( iv_matnr = c_matnr
                            iv_werks = c_here )
      exp = VALUE zcl_alloc_other_plants=>ty_werks_tab( ( c_there ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->others( iv_matnr = c_other
                            iv_werks = c_here )
      exp = VALUE zcl_alloc_other_plants=>ty_werks_tab( ( c_far ) ) ).

  ENDMETHOD.

  METHOD preloading_reads_once.

    " what the feature is for: the database is asked before the loop, and
    " nothing in the loop goes back to it
    mo_cut->preload( VALUE #( ( c_matnr ) ( c_other ) ( c_gone ) ) ).

    DELETE FROM marc WHERE matnr IN ( @c_matnr, @c_other ).
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_not_initial( mo_cut->others(
      iv_matnr = c_matnr
      iv_werks = c_here ) ).
    cl_abap_unit_assert=>assert_not_initial( mo_cut->others(
      iv_matnr = c_other
      iv_werks = c_here ) ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->others( iv_matnr = c_gone
                            iv_werks = c_here )
      msg = 'and a material nobody has is an answered question too' ).

  ENDMETHOD.

  METHOD one_object_serves_two_plants.

    " the asking plant is left out at the answer and not at the read, which
    " is what lets the run of feature 172 keep one of these for the company
    mo_cut->preload( VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->others( iv_matnr = c_matnr
                            iv_werks = c_here )
      exp = VALUE zcl_alloc_other_plants=>ty_werks_tab( ( c_there ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->others( iv_matnr = c_matnr
                            iv_werks = c_there )
      exp = VALUE zcl_alloc_other_plants=>ty_werks_tab( ( c_here ) ) ).

  ENDMETHOD.

ENDCLASS.
