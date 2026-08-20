"! Answers with a fixed list of materials.
CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_matnr TYPE zif_demand_reader=>ty_matnr_tab.

  PRIVATE SECTION.
    DATA mt_matnr TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_matnr = it_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mt_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    rt_demand = VALUE #(
      ( demand_id = 'D1'
        matnr     = iv_matnr
        werks     = iv_werks
        quantity  = '10'
        req_date  = '20260301'
        priority  = '01' ) ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_demand_in_package DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_count TYPE i VALUE 4.

    METHODS every_material
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

    METHODS materials_of
      IMPORTING
        iv_package      TYPE i
        iv_packages     TYPE i DEFAULT c_count
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

    METHODS the_packages_cover_everything FOR TESTING.
    METHODS no_material_is_in_two FOR TESTING.
    METHODS one_package_is_the_whole_plant FOR TESTING.
    METHODS no_split_is_the_whole_plant FOR TESTING.
    METHODS a_package_of_none_is_nothing FOR TESTING.
    METHODS the_same_material_stays_put FOR TESTING.
    METHODS the_work_is_spread FOR TESTING.
    METHODS demand_itself_is_not_split FOR TESTING RAISING cx_static_check.
    METHODS no_split_is_a_package FOR TESTING.
    METHODS a_number_in_range_is_one FOR TESTING.
    METHODS past_the_last_is_not FOR TESTING.
    METHODS half_a_thought_is_not FOR TESTING.

ENDCLASS.


CLASS ltcl_demand_in_package IMPLEMENTATION.

  METHOD every_material.

    DO 40 TIMES.
      APPEND |MAT-{ sy-index WIDTH = 4 ALIGN = RIGHT PAD = '0' }| TO rt_matnr.
    ENDDO.

  ENDMETHOD.

  METHOD materials_of.

    DATA(lo_cut) = CAST zif_demand_reader( NEW zcl_demand_in_package(
      io_demand   = NEW lcl_demand_double( every_material( ) )
      iv_package  = iv_package
      iv_packages = iv_packages ) ).

    rt_matnr = lo_cut->materials_with_demand( c_werks ).

  ENDMETHOD.

  METHOD no_split_is_a_package.

    cl_abap_unit_assert=>assert_true(
      act = zcl_demand_in_package=>is_a_package(
        iv_package  = 0
        iv_packages = 0 )
      msg = 'a plant that never split its run has both numbers empty' ).

  ENDMETHOD.

  METHOD a_number_in_range_is_one.

    cl_abap_unit_assert=>assert_true(
      act = zcl_demand_in_package=>is_a_package(
        iv_package  = 4
        iv_packages = 4 )
      msg = 'the last package of a split is a package like any other' ).

  ENDMETHOD.

  METHOD past_the_last_is_not.

    cl_abap_unit_assert=>assert_false(
      act = zcl_demand_in_package=>is_a_package(
        iv_package  = 5
        iv_packages = 4 )
      msg = 'package five of four matches no material and would look like a quiet night' ).

  ENDMETHOD.

  METHOD half_a_thought_is_not.

    cl_abap_unit_assert=>assert_false(
      act = zcl_demand_in_package=>is_a_package(
        iv_package  = 2
        iv_packages = 0 )
      msg = 'a package number without a count is half a thought' ).
    cl_abap_unit_assert=>assert_false(
      act = zcl_demand_in_package=>is_a_package(
        iv_package  = 0
        iv_packages = 4 )
      msg = 'and a count without a number is the other half' ).

  ENDMETHOD.

  METHOD the_packages_cover_everything.

    DATA lv_total TYPE i.

    DO c_count TIMES.
      lv_total = lv_total + lines( materials_of( sy-index ) ).
    ENDDO.

    cl_abap_unit_assert=>assert_equals(
      act = lv_total
      exp = lines( every_material( ) )
      msg = 'four jobs between them must allocate the whole plant' ).

  ENDMETHOD.

  METHOD no_material_is_in_two.

    DATA(lt_first)  = materials_of( 1 ).
    DATA(lt_second) = materials_of( 2 ).

    LOOP AT lt_first INTO DATA(lv_matnr).
      cl_abap_unit_assert=>assert_false(
        act = xsdbool( line_exists( lt_second[ table_line = lv_matnr ] ) )
        msg = 'two jobs allocating the same material would fight over the stock' ).
    ENDLOOP.

  ENDMETHOD.

  METHOD one_package_is_the_whole_plant.

    cl_abap_unit_assert=>assert_equals(
      act = lines( materials_of( iv_package  = 1
                                 iv_packages = 1 ) )
      exp = lines( every_material( ) )
      msg = 'one package is no split' ).

  ENDMETHOD.

  METHOD no_split_is_the_whole_plant.

    cl_abap_unit_assert=>assert_equals(
      act = lines( materials_of( iv_package  = 0
                                 iv_packages = 0 ) )
      exp = lines( every_material( ) )
      msg = 'a plant that never split its run keeps the run it had' ).

  ENDMETHOD.

  METHOD a_package_of_none_is_nothing.

    cl_abap_unit_assert=>assert_equals(
      act = lines( materials_of( iv_package  = 0
                                 iv_packages = 4 ) )
      exp = lines( every_material( ) )
      msg = 'a package number nobody set must not allocate an empty plant' ).

  ENDMETHOD.

  METHOD the_same_material_stays_put.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_demand_in_package=>package_of(
        iv_matnr    = 'MAT-0001'
        iv_packages = c_count )
      exp = zcl_demand_in_package=>package_of(
        iv_matnr    = 'MAT-0001'
        iv_packages = c_count )
      msg = 'the answer is a property of the material, not of the list it was in' ).

  ENDMETHOD.

  METHOD the_work_is_spread.

    " not an even split, and it does not have to be, but a package holding
    " everything or nothing would make the whole thing pointless
    DO c_count TIMES.
      cl_abap_unit_assert=>assert_true(
        act = xsdbool( lines( materials_of( sy-index ) ) > 2 )
        msg = 'every job must get some of the work' ).
    ENDDO.

  ENDMETHOD.

  METHOD demand_itself_is_not_split.

    DATA(lo_cut) = CAST zif_demand_reader( NEW zcl_demand_in_package(
      io_demand   = NEW lcl_demand_double( every_material( ) )
      iv_package  = 1
      iv_packages = c_count ) ).

    cl_abap_unit_assert=>assert_not_initial(
      act = lo_cut->read_open_demand(
        iv_matnr = 'MAT-0002'
        iv_werks = c_werks )
      msg = 'a caller naming a material outright gets its demand, package or not' ).

  ENDMETHOD.

ENDCLASS.
