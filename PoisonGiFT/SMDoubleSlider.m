//
//  SMDoubleSlider.m
//
//  Copyright (c) 2003 Snowmint Creative Solutions LLC. All rights reserved.
//
#import "SMDoubleSlider.h"
#import "SMDoubleSliderCell.h"

@implementation SMDoubleSlider

+ (Class)cellClass
{
    return [ SMDoubleSliderCell class ];
}

- (void)keyDown:(NSEvent *)theEvent
{
    const unichar	kTabKey = '\t';
    const unichar	kBackTabKey = 25;

    if ( [ [ theEvent characters ] characterAtIndex:0 ] == kTabKey )
    {
        // Tab forwards...Switch from low to high knob tracking, or switch to the next control.
        if ( [ _cell trackingLoKnob ] )
            [ _cell setTrackingLoKnob:NO ];
        else
        {
            [ _cell setTrackingLoKnob:YES ];
            [ super keyDown:theEvent ];
        }
    }
    else if ( [ [ theEvent characters ] characterAtIndex:0 ] == kBackTabKey )
    {
        // Tab backwards...Switch from high knob to low knob tracking, or switch to the next control.
        if ( ![ _cell trackingLoKnob ] )
            [ _cell setTrackingLoKnob:YES ];
        else
            [ super keyDown:theEvent ];
    }
    else
        [ super keyDown:theEvent ];
}

- (BOOL)becomeFirstResponder
{
    BOOL	result = [ super becomeFirstResponder ];

    // Depending on which way we're going through the key loop, select either the hi knob or the lo knob.
    if ( result && [ [ self window ] keyViewSelectionDirection ] != NSDirectSelection )
        [ self setTrackingLoKnob:( [ [ self window ] keyViewSelectionDirection ] == NSSelectingNext ) ];

    return result;
}

#pragma mark -

- (BOOL)trackingLoKnob
{
    return [ _cell trackingLoKnob ];
}

- (void)setTrackingLoKnob:(BOOL)inValue
{
    [ _cell setTrackingLoKnob:inValue ];
}

- (BOOL)lockedSliders
{
    return [ _cell lockedSliders ];
}

- (void)setLockedSliders:(BOOL)inLocked
{
    [ _cell setLockedSliders:inLocked ];
}

#pragma mark -

- (void)setObjectHiValue:(id)obj
{
    [ _cell setObjectHiValue:obj ];
}

- (void)setStringHiValue:(NSString *)aString
{
    [ _cell setStringHiValue:aString ];
}

- (void)setIntHiValue:(int)anInt
{
    [ _cell setIntHiValue:anInt ];
}

- (void)setFloatHiValue:(float)aFloat
{
    [ _cell setFloatHiValue:aFloat ];
}

- (void)setDoubleHiValue:(double)aDouble
{
    [ _cell setDoubleHiValue:aDouble ];
}

- (id)objectHiValue
{
    return [ _cell objectHiValue ];
}

- (NSString *)stringHiValue
{
    return [ _cell stringHiValue ];
}

- (int)intHiValue
{
    return [ _cell intHiValue ];
}

- (float)floatHiValue
{
    return [ _cell floatHiValue ];
}

- (double)doubleHiValue
{
    return [ _cell doubleHiValue ];
}

#pragma mark -

- (void)setObjectLoValue:(id)obj
{
    [ _cell setObjectLoValue:obj ];
}

- (void)setStringLoValue:(NSString *)aString
{
    [ _cell setStringLoValue:aString ];
}

- (void)setIntLoValue:(int)anInt
{
    [ _cell setIntLoValue:anInt ];
}

- (void)setFloatLoValue:(float)aFloat
{
    [ _cell setFloatLoValue:aFloat ];
}

- (void)setDoubleLoValue:(double)aDouble
{
    [ _cell setDoubleLoValue:aDouble ];
}

- (id)objectLoValue
{
    return [ _cell objectLoValue ];
}

- (NSString *)stringLoValue
{
    return [ _cell stringLoValue ];
}

- (int)intLoValue
{
    return [ _cell intLoValue ];
}

- (float)floatLoValue
{
    return [ _cell floatLoValue ];
}

- (double)doubleLoValue
{
    return [ _cell doubleLoValue ];
}

@end
