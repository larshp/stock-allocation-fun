CLASS cl_stub_bal DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_msg_tab TYPE STANDARD TABLE OF bal_s_msg WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Open a log and hand out a handle for it</p>
    "!
    "! Carries the part of BAL_LOG_CREATE the custom code depends on: a log
    "! without an object is refused, otherwise a handle is handed out and the
    "! log exists until the session ends.
    "!
    "! @parameter is_log     | <p class="shorttext synchronized">Log header</p>
    "! @parameter rv_handle  | <p class="shorttext synchronized">Handle of the new log, initial if refused</p>
    CLASS-METHODS create
      IMPORTING
        is_log           TYPE bal_s_log
      RETURNING
        VALUE(rv_handle) TYPE balloghndl.

    "! <p class="shorttext synchronized">Add a message to an open log</p>
    "!
    "! @parameter iv_handle | <p class="shorttext synchronized">Handle of an open log</p>
    "! @parameter is_msg    | <p class="shorttext synchronized">Message to add</p>
    "! @parameter rv_added  | <p class="shorttext synchronized">False if the handle is not an open log</p>
    CLASS-METHODS add_message
      IMPORTING
        iv_handle       TYPE balloghndl
        is_msg          TYPE bal_s_msg
      RETURNING
        VALUE(rv_added) TYPE abap_bool.

    "! <p class="shorttext synchronized">What one open log has been told so far</p>
    "!
    "! @parameter iv_handle | <p class="shorttext synchronized">Handle of an open log</p>
    "! @parameter rt_msg    | <p class="shorttext synchronized">Messages in the order they were added</p>
    CLASS-METHODS messages_of
      IMPORTING
        iv_handle     TYPE balloghndl
      RETURNING
        VALUE(rt_msg) TYPE ty_msg_tab.

    "! <p class="shorttext synchronized">Write an open log to the database</p>
    "!
    "! @parameter iv_handle | <p class="shorttext synchronized">Handle of an open log</p>
    "! @parameter rv_saved  | <p class="shorttext synchronized">False if the handle is not an open log</p>
    CLASS-METHODS save
      IMPORTING
        iv_handle       TYPE balloghndl
      RETURNING
        VALUE(rv_saved) TYPE abap_bool.

    "! <p class="shorttext synchronized">Whether a log has reached the database</p>
    "!
    "! @parameter iv_handle | <p class="shorttext synchronized">Handle of an open log</p>
    "! @parameter rv_saved  | <p class="shorttext synchronized">True once BAL_DB_SAVE has had it</p>
    CLASS-METHODS is_saved
      IMPORTING
        iv_handle       TYPE balloghndl
      RETURNING
        VALUE(rv_saved) TYPE abap_bool.

    "! <p class="shorttext synchronized">Handle of the log opened last</p>
    "!
    "! @parameter rv_handle | <p class="shorttext synchronized">Initial when no log has been opened</p>
    CLASS-METHODS last_handle
      RETURNING
        VALUE(rv_handle) TYPE balloghndl.

    "! <p class="shorttext synchronized">Forget every log, as a new session would</p>
    CLASS-METHODS reset.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_log,
        handle TYPE balloghndl,
        header TYPE bal_s_log,
        msg    TYPE ty_msg_tab,
        saved  TYPE abap_bool,
      END OF ty_log.
    TYPES ty_log_tab TYPE STANDARD TABLE OF ty_log WITH EMPTY KEY.

    CLASS-DATA gt_log    TYPE ty_log_tab.
    CLASS-DATA gv_number TYPE i.

ENDCLASS.


CLASS cl_stub_bal IMPLEMENTATION.

  METHOD create.

    IF is_log-object IS INITIAL.
      RETURN.
    ENDIF.

    gv_number = gv_number + 1.
    rv_handle = |HANDLE{ gv_number WIDTH = 16 ALIGN = RIGHT PAD = '0' }|.

    APPEND VALUE #(
      handle = rv_handle
      header = is_log ) TO gt_log.

  ENDMETHOD.

  METHOD add_message.

    FIELD-SYMBOLS <ls_log> TYPE ty_log.

    READ TABLE gt_log ASSIGNING <ls_log> WITH KEY handle = iv_handle.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    APPEND is_msg TO <ls_log>-msg.
    rv_added = abap_true.

  ENDMETHOD.

  METHOD messages_of.

    READ TABLE gt_log INTO DATA(ls_log) WITH KEY handle = iv_handle.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rt_msg = ls_log-msg.

  ENDMETHOD.

  METHOD save.

    FIELD-SYMBOLS <ls_log> TYPE ty_log.

    READ TABLE gt_log ASSIGNING <ls_log> WITH KEY handle = iv_handle.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    <ls_log>-saved = abap_true.
    rv_saved = abap_true.

  ENDMETHOD.

  METHOD is_saved.

    READ TABLE gt_log INTO DATA(ls_log) WITH KEY handle = iv_handle.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_saved = ls_log-saved.

  ENDMETHOD.

  METHOD last_handle.

    IF gt_log IS INITIAL.
      RETURN.
    ENDIF.

    rv_handle = gt_log[ lines( gt_log ) ]-handle.

  ENDMETHOD.

  METHOD reset.

    CLEAR gt_log.
    CLEAR gv_number.

  ENDMETHOD.

ENDCLASS.
