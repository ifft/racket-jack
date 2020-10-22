#lang racket

; vim:ft=scheme:lisp:ai
(require ffi/unsafe
         ffi/unsafe/define
         ffi/unsafe/define/conventions)

(provide _jack_options_t)
(define _jack_options_t
  (_bitmask '(JackNullOption
               JackNoStartServer
               JackUseExactName
               JackServerName
               JackLoadName
               JackLoadInit
               JackSessionID)))

(provide _jack_status_t)
(define _jack_status_t
  (_bitmask '(JackFailure = 1
                          JackInvalidOption
                          JackNameNotUnique
                          JackServerStarted
                          JackServerFailed
                          JackServerError
                          JackNoSuchClient
                          JackLoadFailure
                          JackInitFailure
                          JackShmFailure
                          JackVersionError
                          JackBackendError
                          JackClientZombie)))

(provide _jack_port_flags_t)
(define _jack_port_flags_t
  (_bitmask '(JackPortIsInput = 1
                              JackPortIsOutput
                              JackPortIsPhysical
                              JackPortCanMonitor
                              JackPortIsTerminal)
            _ulong))

(provide JACK_DEFAULT_AUDIO_TYPE)
(define JACK_DEFAULT_AUDIO_TYPE "32 bit float mono audio")

(provide JACK_DEFAULT_MIDI_TYPE)
(define JACK_DEFAULT_MIDI_TYPE "8 bit raw midi")

(provide _jack_sample_t)
(define _jack_sample_t _float)

(provide _jack_client_t)
(define-cpointer-type _jack_client_t)

(provide _jack_port_t)
(define-cpointer-type _jack_port_t)

(provide _jack_p_sample_t)
(define-cpointer-type _jack_p_sample_t)

(provide _jack_nframes_t)
(define _jack_nframes_t _uint32)

(define-ffi-definer jack-define (ffi-lib "libjack")
                    #:make-c-id convention:hyphen->underscore)

(provide jack-client-open)
(jack-define
  jack-client-open
  (_fun _string _jack_options_t (status : (_ptr o _jack_status_t))
        -> (handle : _jack_client_t)
        -> (values handle status)))

(provide jack-client-close)
(jack-define jack-client-close
             (_fun _jack_client_t -> _int))

(provide jack-get-sample-rate)
(jack-define jack-get-sample-rate
             (_fun _jack_client_t -> _uint32))

(provide jack-port-register)
(jack-define jack-port-register
             (_fun _jack_client_t
                   _string
                   _string
                   _jack_port_flags_t
                   _ulong -> (p : _jack_port_t) -> p))

(provide handle-jack-callback)
(define (handle-jack-callback thunk)
  (thunk))

(provide _jack_process_callback_t)
(define _jack_process_callback_t
  (_fun #:keep #t #:async-apply handle-jack-callback _jack_nframes_t _pointer -> _int))

(provide _jack_shutdown_callback_t)
(define _jack_shutdown_callback_t
  (_fun #:async-apply handle-jack-callback _pointer -> _void))

(provide jack-set-process-callback)
(jack-define jack-set-process-callback
             (_fun _jack_client_t _jack_process_callback_t _pointer -> _int))

(provide jack-activate)
(jack-define jack-activate
             (_fun _jack_client_t -> (ret : _int) -> ret))

(provide jack-port-get-buffer)
(jack-define jack-port-get-buffer
 (_fun _jack_port_t _jack_nframes_t -> (buf : _jack_p_sample_t/null) -> buf))

(provide jack-on-shutdown)
(jack-define jack-on-shutdown
             (_fun _jack_client_t _jack_shutdown_callback_t _pointer -> _void))

