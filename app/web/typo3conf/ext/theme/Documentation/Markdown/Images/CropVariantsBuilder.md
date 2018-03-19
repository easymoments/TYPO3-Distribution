Back to [Index](../Index.md) / Back to [Images Index](Index.md)

---

# CropVariants Builder :construction_worker_man:

> `JosefGlatz\Theme\Backend\CropVariants\Builder->getInstance()` **FTW
> :+1:**

**Learn the usage of CropVariants Builder by reading the code
examples!** You get a good overview just by comparing with/-out the
builder:

1. [Example 1](#example-1-set-a-global-or-default-cropvariants-configuration):
   Global/Default cropVariants configuration for TYPO3 instance
2. [Example 2](#example-2-set-custom-cropvariants-for-a-specific-field-of-a-specific-table-pagestx_theme_nav_image):
   Custom cropVariants configuration for a specific field of a specific
   table


[**Overview of defaults and predefined presets**](#overview-of-defaultspredefined-presets)

1. [aspectRatio presets](#predefined-aspectratios)
2. [coverArea presets](#predefined-coverareas)
3. [cropArea presets](#predefined-cropareas)
4. [List of default cropVariants]()

---

## Example 1: Set a global-or-default cropVariants configuration

`EXT:theme/Configuration/TCA/Overrides/sys_file_reference.php`

The "default" cropVariants configuration is set as a project default. 6
allowed aspect ratios are configured in this example.

### Before (TYPO3 Core only)

**The downside:**
* All options are set without defaults
* writing the configuration is error-prone (because you have no
  autocompletion)
* the cropArea is set manually (no centralized preset)
* allowed aspect ratios are set manually (no centralized presets)
* manual title option string

```php
<?php
defined('TYPO3_MODE') || die('Access denied.');

call_user_func(
    function ($extKey, $table) {
        $languageFileBePrefix = 'LLL:EXT:' . $extKey . '/Resources/Private/Language/locallang_BackendGeneral.xlf:';

        $tca = [
            'columns' => [
                'crop' => [
                    'config' => [
                        'cropVariants' => [
                            'default' => [
                                'title' => $languageFileBePrefix . 'crop_variants.default.label',
                                'coverAreas' => [],
                                'cropArea' => [
                                    'x' => '0.0',
                                    'y' => '0.0',
                                    'width' => '1.0',
                                    'height' => '1.0'
                                ],
                                'allowedAspectRatios' => [
                                    '3:2' => [
                                        'title' => 'LLL:EXT:lang/Resources/Private/Language/locallang_wizards.xlf:imwizard.ratio.3_2',
                                        'value' => 3 / 2
                                    ],
                                    '2:3' => [
                                        'title' => '2:3',
                                        'value' => 2 / 3
                                    ],
                                    '4:3' => [
                                        'title' => 'LLL:EXT:lang/Resources/Private/Language/locallang_wizards.xlf:imwizard.ratio.4_3',
                                        'value' => 4 / 3
                                    ],
                                    '3:4' => [
                                        'title' => '3:4',
                                        'value' => 3 / 4
                                    ],
                                    '1:1' => [
                                        'title' => 'LLL:EXT:lang/Resources/Private/Language/locallang_wizards.xlf:imwizard.ratio.1_1',
                                        'value' => 1.0
                                    ],
                                    'NaN' => [
                                        'title' => 'LLL:EXT:lang/Resources/Private/Language/locallang_wizards.xlf:imwizard.ratio.free',
                                        'value' => 0.0
                                    ],
                                ],
                                'selectedRatio' => 'NaN'
                            ],
                        ],
                    ],
                ],
            ]
        ];
        $GLOBALS['TCA'][$table] = array_replace_recursive($GLOBALS['TCA'][$table], $tca);
    },
    'theme',
    'sys_file_reference'
);
```

### Afterwards (with CropVariants Builder)

**The advantages:**
* Enjoy IDE auto completion
* easy to read
* 36 lines of code less
* add a cropVariant..
  * the cropVariant constructor tries to set title LLL strings based on
    the given CropVariant name
  * the desired cropArea preset is automatically set to default (of
    course, you can set the cropArea based on presets)
  * all default allowedAspectRatios are set with one line of code
  * setting the selectedRatio is super easy
  * Retrieve final cropVariant configuration with `get()` method
* finally persist the cropVariants configuration just with the oneliner
  * keep in mind: you have to use `persistToDefaultTableTca()` for
    `sys_file_reference` table


```php
<?php
defined('TYPO3_MODE') || die('Access denied.');

call_user_func(
    function ($extKey, $table) {
        \JosefGlatz\Theme\Backend\CropVariants\Builder::getInstance($table, 'crop')
            ->addCropVariant(
                \JosefGlatz\Theme\Backend\CropVariants\CropVariant::create('default')
                    ->setCropArea(\JosefGlatz\Theme\Backend\CropVariants\Defaults\CropArea::get())
                    ->addAllowedAspectRatios(\JosefGlatz\Theme\Backend\CropVariants\Defaults\AspectRatio::getDefaults())
                    ->setSelectedRatio('NaN')
                    ->get()
            )
            ->persistToDefaultTableTca();
    },
    'theme',
    'sys_file_reference'
);
```

---

## Example 2: Set custom cropVariants for a specific field of a specific table (`pages.tx_theme_nav_image`)

`EXT:theme/Configuration/TCA/Overrides/pages.php`

A common usecase: You add a custom field to the `pages` table and want a
custom cropVariants configuration for this particular field. The TYPO3
editor can add 1 image per page and have to set 3 crops for breakpoint
xs, md and lg. All three with same allowed aspectRatios.

### Before (TYPO3 Core only)

**The downside:**
* All options are set without defaults and aren't configured centralized
* writing the configuration is error-prone (because you have no
  autocompletion)
* cropAreas are always set manually (no centralized preset, no automatic
  fallback to default cropArea)
* e.g. if you add some additional cropVariant for the project as
  default, you have to disable the new default cropVariant here (and in
  every other file)
* allowed aspect ratios are set manually (no centralized presets)
* cropVariant title LLL string isn't automatically fetched from you
  xliff file

```php
<?php
defined('TYPO3_MODE') || die('Access denied.');

call_user_func(
    function ($extKey, $table) {
        $languageFileBePrefix = 'LLL:EXT:' . $extKey . '/Resources/Private/Language/locallang_BackendGeneral.xlf:';

        $additionalColumns = [
            'tx_theme_nav_image' => [
                'exclude' => true,
                'label' => $languageFileBePrefix . 'field.pages.tx_theme_nav_image.label',
                'config' => \TYPO3\CMS\Core\Utility\ExtensionManagementUtility::getFileFieldTCAConfig('tx_theme_nav_image', [
                    'overrideChildTca' => [
                        'types' => [
                            \TYPO3\CMS\Core\Resource\File::FILETYPE_IMAGE => [
                                'showitem' => '
                                alternative,title,
                                --linebreak--,crop,
                                --palette--;;filePalette',
                                'columnsOverrides' => [],
                            ],
                        ],
                        'columns' => [
                            'crop' => [
                                'config' => [
                                    'cropVariants' => [
                                        'default' => [
                                            'disabled' => true
                                        ],
                                        'xs' => [
                                            'title' => $languageFileBePrefix . 'crop_variants.xs.label',
                                            'coverAreas' => [],
                                            'cropArea' => [
                                                'x' => '0.0',
                                                'y' => '0.0',
                                                'width' => '1.0',
                                                'height' => '1.0'
                                            ],
                                            'allowedAspectRatios' => [
                                                '4:3' => [
                                                    'title' => 'LLL:EXT:lang/Resources/Private/Language/locallang_wizards.xlf:imwizard.ratio.4_3',
                                                    'value' => 4 / 3
                                                ],
                                            ],
                                        ],
                                        'md' => [
                                            'title' => $languageFileBePrefix . 'crop_variants.md.label',
                                            'coverAreas' => [],
                                            'cropArea' => [
                                                'x' => '0.0',
                                                'y' => '0.0',
                                                'width' => '1.0',
                                                'height' => '1.0'
                                            ],
                                            'allowedAspectRatios' => [
                                                '4:3' => [
                                                    'title' => 'LLL:EXT:lang/Resources/Private/Language/locallang_wizards.xlf:imwizard.ratio.4_3',
                                                    'value' => 4 / 3
                                                ],
                                            ],
                                        ],
                                        'lg' => [
                                            'title' => $languageFileBePrefix . 'crop_variants.lg.label',
                                            'coverAreas' => [],
                                            'cropArea' => [
                                                'x' => '0.0',
                                                'y' => '0.0',
                                                'width' => '1.0',
                                                'height' => '1.0'
                                            ],
                                            'allowedAspectRatios' => [
                                                '4:3' => [
                                                    'title' => 'LLL:EXT:lang/Resources/Private/Language/locallang_wizards.xlf:imwizard.ratio.4_3',
                                                    'value' => 4 / 3
                                                ],
                                            ],
                                        ],
                                    ],
                                ],
                            ],
                        ],
                    ],
                    'maxitems' => 1,
                ],
                    $GLOBALS['TYPO3_CONF_VARS']['GFX']['imagefile_ext']
                )
            ],
        ];
        \TYPO3\CMS\Core\Utility\ExtensionManagementUtility::addTCAcolumns($table, $additionalColumns);
    },
    'theme',
    'pages'
);
```


### Afterwards (with CropVariants Builder)

**The advantages:**
* add cropVariants configuration after adding the custom TCA column
* Enjoy IDE auto completion
* 32 lines of code less
* easy to read
* add cropVariants with much fewer lines of code
* finally persist the cropVariants configuration with a oneliner
  (`persistToTca()`)
* combine other cropVariants configurations to this code block, so you
  have a good overview

```php
<?php
defined('TYPO3_MODE') || die('Access denied.');

call_user_func(
    function ($extKey, $table) {
        $languageFileBePrefix = 'LLL:EXT:' . $extKey . '/Resources/Private/Language/locallang_BackendGeneral.xlf:';

        $additionalColumns = [
            'tx_theme_nav_image' => [
                'exclude' => true,
                'label' => $languageFileBePrefix . 'field.pages.tx_theme_nav_image.label',
                'config' => \TYPO3\CMS\Core\Utility\ExtensionManagementUtility::getFileFieldTCAConfig('tx_theme_nav_image', [
                    'overrideChildTca' => [
                        'types' => [
                            \TYPO3\CMS\Core\Resource\File::FILETYPE_IMAGE => [
                                'showitem' => '
                                alternative,title,
                                --linebreak--,crop,
                                --palette--;;filePalette',
                                'columnsOverrides' => [],
                            ],
                        ],
                    ],
                    'maxitems' => 1,
                ],
                    $GLOBALS['TYPO3_CONF_VARS']['GFX']['imagefile_ext']
                )
            ],
        ];
        \TYPO3\CMS\Core\Utility\ExtensionManagementUtility::addTCAcolumns($table, $additionalColumns);

        /**
         * Set cropVariants configuration
         */
        \JosefGlatz\Theme\Backend\CropVariants\Builder::getInstance($table, 'tx_theme_nav_image')
            ->disableDefaultCropVariants()
            ->addCropVariant(
                \JosefGlatz\Theme\Backend\CropVariants\CropVariant::create('xs')
                    ->addAllowedAspectRatios(\JosefGlatz\Theme\Backend\CropVariants\Defaults\AspectRatio::get(['4:3']))
                    ->get()
            )
            ->addCropVariant(
                \JosefGlatz\Theme\Backend\CropVariants\CropVariant::create('md')
                    ->addAllowedAspectRatios(\JosefGlatz\Theme\Backend\CropVariants\Defaults\AspectRatio::get(['4:3']))
                    ->get()
            )
            ->addCropVariant(
                \JosefGlatz\Theme\Backend\CropVariants\CropVariant::create('lg')
                    ->addAllowedAspectRatios(\JosefGlatz\Theme\Backend\CropVariants\Defaults\AspectRatio::get(['4:3']))
                    ->get()
            )
            ->persistToTca();
    },
    'theme',
    'pages'
);
```


---

## Overview of defaults/predefined presets

All listed defaults/presets can be configured as arrays within
`JosefGlatz\Theme\Backend\CropVariants\Defaults`. *The actual plan is to
make them configurable via a simple yaml file. ([Issue 280](https://github.com/josefglatz/TYPO3-Distribution/issues/280))*

### Predefined aspectRatios

|   Key    |                               Description                                |
|:---------|:-------------------------------------------------------------------------|
| `3:1`    | Often used for wide sujet images                                         |
| `2:1`    | Often used for wide sujet images                                         |
| `1.91:1` | Suggested by Facebook (and Twitter) for open graph / twitter card images |
| `16:9`   | Common video standard                                                    |
| `3:2`    | Common D-/SLR format photography                                         |
| `2:3`    | *(portrait)*                                                             |
| `4:3`    | Common point and shoot format photography                                |
| `3:4`    | *(portrait)*                                                             |
| `5:4`    | Common large and medium format photography                               |
| `4:5`    | *(portrait)*                                                             |
| `1:1`    | Square image format                                                      |
| `NaN`    | Free ratio (no ratio limitation)                                         |

### Predefined coverAreas

|      Key      |                                        Usage Scenario                                         |
|:--------------|:----------------------------------------------------------------------------------------------|
| `1_1_circle`  | Can be used for square images with CSS `border-radius: 50%` for example.                      |
| `lower_third` | Can be used for images where the lower third of the image area is overlayed by a DOM element. |

### Predefined cropAreas

|    Key    |                   Description                   |
|:----------|:------------------------------------------------|
| `default` | Default (biggest possible) (X0, Y0, W1.0, H1.0) |

### List of default cropVariants

The list of default cropVariants contains an array with all as default
set cropVariants set for `sys_file_reference.crop` for this TYPO3
instance/project.

|    Key    |
|:----------|
| `default` |

> The list of default cropVariants is actually used if you use
> `disableDefaultCropVariants()` method.
