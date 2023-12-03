<?php

namespace App\Enums;

use BenSampo\Enum\Enum;

/**
 * @method static static OptionOne()
 * @method static static OptionTwo()
 * @method static static OptionThree()
 */
final class TopicStatus extends Enum
{
    const PENDING = 0;
    const APPROVE = 1;
    const REJECT = 2;
}
