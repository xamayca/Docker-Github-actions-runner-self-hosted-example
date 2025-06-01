<?php

namespace App\Entity;

final class Post
{
    public function __construct(

        private(set) int $id = 0 {
            get => $this->id;
        },

        private(set) string $title = '' {
            set {

                if(empty($value))
                {
                    throw new \Exception("Le titre ne peut pas être vide");
                }

                if (strlen($value) < 10 || strlen($value) > 150 ) {
                    throw new \Exception("Le titre doit être compris entre 10 et 150 caractères");
                }

                $this->title = $value;
            }
        },

        private(set) string $content = '' {
            set {

                if (empty($value)) {
                    throw new \Exception("Le contenu ne peut pas être vide");
                }

                if (strlen($value) < 10 || strlen($value) > 150) {
                    throw new \Exception("Le contenu doit être compris entre 10 et 150 caractères");
                }

                $this->content = $value;
            }
        },
    )
    {}
}