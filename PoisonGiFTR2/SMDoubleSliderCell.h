/*!	@header	SMDoubleSliderCell.h
    @discussion
    This is subclass of NSSliderCell that supports two knobs - a low knob and a high knob.  The user
    can set either knob in the range of the slider, as long as the low knob is always lower
    in value than the high knob.

    Copyright (c) 2003 Snowmint Creative Solutions LLC. All rights reserved.
*/
#import <AppKit/NSSliderCell.h>

/*!	@class		SMDoubleSliderCell
    @discussion	This subclass of NSSliderCell has two knobs - a low knob and a high knob.  The user
                can set either knob in the range of the slider, as long as the low knob is always lower
                in value than the high knob.
*/
@interface SMDoubleSliderCell : NSSliderCell
{
@protected
    double	_sm_loValue;
    double	_sm_saveValue;
    struct {
    unsigned char	lockedSliders : 1;
    unsigned char	isTrackingLoKnob : 1;
    unsigned char	mouseTrackingSwapped : 1;
    unsigned char	removeFocusRingStyle : 1;
    } _sm_flags;
}

/*!	@method		trackingLoKnob
    @discussion	Are we tracking on the low knob or the high knob?  The end user can change this by clicking on
                one knob or the other, or by using the tab key to cycle through the knobs.

                The standard methods -doubleValue, -intValue, -setDoubleValue:, -setIntValue: etc. will
                all use either the low or the high knob depending on this setting.
    @result	YES if the double slider is tracking on the low knob.
*/
- (BOOL)trackingLoKnob;
/*!	@method		setTrackingLoKnob:
    @discussion	Are we tracking on the low knob or the high knob?  Note that the end user can change this by
                clicking on one knob or the other, or by using the tab key to cycle through the knobs.

                The standard methods -doubleValue, -intValue, -setDoubleValue:, -setIntValue: etc. will
                all use either the low or the high knob depending on this setting.
    @param	inValue		YES if you want to track on the low knob.
*/
- (void)setTrackingLoKnob:(BOOL)inValue;

/*!	@method		lockedSliders
    @discussion	Determine if the two sliders are locked together.  The low and high knobs will always have
                the same value if this is true.  The end user can not change this setting at run time.

                <b>NOTE: This value is currently saved, but the locking behavior is unimplemented.</b>
    @result	YES if the two knobs are locked together.
*/
- (BOOL)lockedSliders;
/*!	@method		setLockedSliders:
    @discussion	Lock the two sliders together, so it functions just like a normal NSSlider.  The low and high
                knobs will have the same value.  The end user can not change this setting at run time.

                The low knob value gets set to the high knob value immediately.

                <b>NOTE: This value is currently saved, but the locking behavior is unimplemented.</b>
    @param	inLocked	YES if you want to lock the two knobs together.
*/
- (void)setLockedSliders:(BOOL)inLocked;

/*!	@method	setObjectHiValue:
    @discussion	Sets the receiver's object value to object.
                The value is pinned between the low knob and maximum slider values.
    @param	obj		An object containing a numeric value.
*/
- (void)setObjectHiValue:(id)obj;
/*!	@method	setStringHiValue:
    @discussion Sets the high knob value of the receiver to aString. In its implementation, this method invokes
                setObjectValue:. If no formatter is assigned to the receiver, or if the formatter cannot
                "translate" aString to an underlying object, the receiver is flagged as having an invalid
                object.
                The value is pinned between the low knob and maximum slider values.
    @param	aString		Should be a string containing a number.
*/
- (void)setStringHiValue:(NSString *)aString;
/*!	@method	setIntHiValue:
    @discussion	Sets the high knob value of the receiver to an object anInt, representing an integer value.
                In its implementation, this method invokes setObjectValue:.
                The value is pinned between the low knob and maximum slider values.
    @param	anInt		An integer to set the high knob value to.
*/
- (void)setIntHiValue:(int)anInt;
/*!	@method	setFloatHiValue:
    @discussion	Sets the high knob value of the receiver to an object aFloat, representing a float value.
                In its implementation, this method invokes setObjectValue:.
                The value is pinned between the low knob and maximum slider values.
    @param	aFloat		An floating point number to set the high knob value to.
*/
- (void)setFloatHiValue:(float)aFloat;
/*!	@method	setDoubleHiValue:
    @discussion	Sets the high knob value of the receiver to an object aDouble, representing a double value.
                In its implementation, this method invokes setObjectValue:.
                The value is pinned between the low knob and maximum slider values.
    @param	aDouble		An double precision number to set the high knob value to.
*/
- (void)setDoubleHiValue:(double)aDouble;
/*!	@method	objectHiValue
    @discussion Returns the receiver's high knob value as an Objective-C object if a valid object has been
                associated with the receiver; otherwise, returns nil. To be valid, the receiver must
                have a formatter capable of converting the object to and from its textual representation.
    @result		The receiver's high knob value as an Objective-C object.
*/
- (id)objectHiValue;
/*!	@method	stringHiValue
    @discussion Returns the receiver's high knob value as an NSString as converted by the receiver's
                formatter, if one exists. If no formatter exists and the value is an NSString, returns the
                value as aa plain, attributed, or localized formatted string. If the value is not an NSString
                or can't be converted to one, returns an empty string.
    @result		The receiver's high knob value as an NSString object.
*/
- (NSString *)stringHiValue;
/*!	@method intHiValue
    @discussion	Returns the receiver's high knob value as an int.
    @result		The receiver's high knob value as an int.
*/
- (int)intHiValue;
/*!	@method floatHiValue
    @discussion	Returns the receiver's high knob value as a float.
    @result		The receiver's high knob value as a float.
*/
- (float)floatHiValue;
/*!	@method doubleHiValue
    @discussion	Returns the receiver's high knob value as a double.
    @result		The receiver's high knob value as a double.
*/
- (double)doubleHiValue;

/*!	@method	setObjectLoValue:
    @discussion	Sets the receiver's object value to object.
                The value is pinned between the low knob and maximum slider values.
    @param	obj		An object containing a numeric value.
*/
- (void)setObjectLoValue:(id)obj;
/*!	@method	setStringLoValue:
    @discussion Sets the low knob value of the receiver to aString. In its implementation, this method invokes
                setObjectValue:. If no formatter is assigned to the receiver, or if the formatter cannot
                "translate" aString to an underlying object, the receiver is flagged as having an invalid
                object.
                The value is pinned between the minimum and high knob slider values.
    @param	aString		Should be a string containing a number.
*/
- (void)setStringLoValue:(NSString *)aString;
/*!	@method	setIntLoValue:
    @discussion	Sets the low knob value of the receiver to an object anInt, representing an integer value.
                In its implementation, this method invokes setObjectValue:.
                The value is pinned between the minimum and high knob slider values.
    @param	anInt		An integer to set the low knob value to.
*/
- (void)setIntLoValue:(int)anInt;
/*!	@method	setFloatLoValue:
    @discussion	Sets the low knob value of the receiver to an object aFloat, representing a float value.
                In its implementation, this method invokes setObjectValue:.
                The value is pinned between the minimum and high knob slider values.
    @param	aFloat		An floating point number to set the low knob value to.
*/
- (void)setFloatLoValue:(float)aFloat;
/*!	@method	setDoubleLoValue:
    @discussion	Sets the low knob value of the receiver to an object aDouble, representing a double value.
                In its implementation, this method invokes setObjectValue:.
                The value is pinned between the minimum and high knob slider values.
    @param	aDouble		An double precision number to set the low knob value to.
*/
- (void)setDoubleLoValue:(double)aDouble;
/*!	@method	objectLoValue
    @discussion Returns the receiver's low knob value as an Objective-C object if a valid object has been
                associated with the receiver; otherwise, returns nil. To be valid, the receiver must
                have a formatter capable of converting the object to and from its textual representation.
    @result		The receiver's low knob value as an Objective-C object.
*/
- (id)objectLoValue;
/*!	@method	stringLoValue
    @discussion Returns the receiver's low knob value as an NSString as converted by the receiver's
                formatter, if one exists. If no formatter exists and the value is an NSString, returns the
                value as aa plain, attributed, or localized formatted string. If the value is not an NSString
                or can't be converted to one, returns an empty string.
    @result		The receiver's low knob value as an NSString object.
*/
- (NSString *)stringLoValue;
/*!	@method intLoValue
    @discussion	Returns the receiver's low knob value as an int.
    @result		The receiver's low knob value as an int.
*/
- (int)intLoValue;
/*!	@method floatLoValue
    @discussion	Returns the receiver's low knob value as a float.
    @result		The receiver's low knob value as a float.
*/
- (float)floatLoValue;
/*!	@method doubleLoValue
    @discussion	Returns the receiver's low knob value as a double.
    @result		The receiver's low knob value as a double.
*/
- (double)doubleLoValue;

@end
